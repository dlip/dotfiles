{ ... }:
{
  flake.modules.nixos.hermesVmHost =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.services.hermesVmHost;

      vmName = cfg.vmName;
      diskPath = cfg.diskPath;
      diskSize = cfg.diskSize;
      memoryMiB = cfg.memoryMiB;
      vcpus = cfg.vcpus;
      bridgeName = cfg.bridge;
      lanInterface = cfg.lanInterface;

      # Domain XML for the libvirt-managed VM. Defined here rather than via
      # `virtualisation.libvirtd.qemu.*` because we want full control over the
      # virtiofs share, network bridge, and disk format.
      #
      # The qcow2 at `diskPath` is created on first boot by hermes-vm-disk.service
      # below (qemu-img create -f qcow2 -o preallocation=metadata ...). The OS
      # image itself is laid down by `bin/hvm-install` which runs `nixos-generators
      # -f qcow` against the seed flake and `dd`s the result over diskPath. After
      # that first install the agent owns its own /etc/nixos and we never touch
      # the disk from the host again (except for snapshots).
      domainXml = pkgs.writeText "${vmName}.xml" ''
        <domain type='kvm'>
          <name>${vmName}</name>
          <memory unit='MiB'>${toString memoryMiB}</memory>
          <currentMemory unit='MiB'>${toString memoryMiB}</currentMemory>
          <vcpu placement='static'>${toString vcpus}</vcpu>
          <os>
            <type arch='x86_64' machine='q35'>hvm</type>
            <boot dev='hd'/>
          </os>
          <features>
            <acpi/>
            <apic/>
          </features>
          <cpu mode='host-passthrough' check='none' migratable='on'/>
          <clock offset='utc'/>
          <on_poweroff>destroy</on_poweroff>
          <on_reboot>restart</on_reboot>
          <on_crash>restart</on_crash>
          <pm>
            <suspend-to-mem enabled='no'/>
            <suspend-to-disk enabled='no'/>
          </pm>
          <devices>
            <emulator>${pkgs.qemu_kvm}/bin/qemu-system-x86_64</emulator>
            <disk type='file' device='disk'>
              <driver name='qemu' type='qcow2' cache='none' io='native' discard='unmap'/>
              <source file='${diskPath}'/>
              <target dev='vda' bus='virtio'/>
            </disk>
            <interface type='bridge'>
              <source bridge='${bridgeName}'/>
              <model type='virtio'/>
            </interface>
            <serial type='pty'><target port='0'/></serial>
            <console type='pty'><target type='serial' port='0'/></console>
            <channel type='unix'>
              <target type='virtio' name='org.qemu.guest_agent.0'/>
            </channel>
            <rng model='virtio'>
              <backend model='random'>/dev/urandom</backend>
            </rng>
            <!-- Shared memory for virtiofs -->
            <memoryBacking>
              <source type='memfd'/>
              <access mode='shared'/>
            </memoryBacking>
            <!-- virtiofs share: host /run/secrets -> guest /run/host-secrets -->
            <filesystem type='mount' accessmode='passthrough'>
              <driver type='virtiofs'/>
              <source dir='/run/secrets'/>
              <target dir='hermes-secrets'/>
            </filesystem>
          </devices>
        </domain>
      '';

      # Wrapper for snapshotting the qcow2. Run before any agent-driven
      # nixos-rebuild from inside the VM (or manually any time you want a
      # known-good restore point).
      hvm-snap = pkgs.writeShellApplication {
        name = "hvm-snap";
        runtimeInputs = with pkgs; [
          libvirt
          qemu_kvm
          coreutils
        ];
        text = ''
          set -euo pipefail
          action="''${1:-list}"
          tag="''${2:-pre-$(date +%Y%m%d-%H%M%S)}"
          case "$action" in
            list)
              qemu-img snapshot -l ${diskPath}
              ;;
            create)
              # Quiesce via guest-agent if up, otherwise just snapshot the
              # qcow2 cold. The agent's nixos-rebuild already commits to git
              # so the VM-side history is the primary log; this is just the
              # filesystem-level safety net.
              echo "creating qcow2 snapshot $tag" >&2
              qemu-img snapshot -c "$tag" ${diskPath}
              ;;
            apply)
              echo "reverting qcow2 to snapshot $tag (VM must be off)" >&2
              virsh destroy ${vmName} >/dev/null 2>&1 || true
              qemu-img snapshot -a "$tag" ${diskPath}
              virsh start ${vmName}
              ;;
            delete)
              qemu-img snapshot -d "$tag" ${diskPath}
              ;;
            *)
              echo "usage: hvm-snap [list|create [tag]|apply <tag>|delete <tag>]" >&2
              exit 64
              ;;
          esac
        '';
      };
    in
    {
      options.services.hermesVmHost = {
        enable = lib.mkEnableOption "Hermes agent VM (libvirt + KVM)";

        vmName = lib.mkOption {
          type = lib.types.str;
          default = "hermes-agent";
          description = "libvirt domain name.";
        };

        diskPath = lib.mkOption {
          type = lib.types.path;
          default = "/mnt/services/hermes-vm/disk.qcow2";
          description = ''
            qcow2 disk image path. Created (sparse, fixed virtual size) on
            first boot if missing. The agent's NixOS lives entirely on this
            image; back it up the same way you'd back up any host.
          '';
        };

        diskSize = lib.mkOption {
          type = lib.types.str;
          default = "32G";
          description = "Virtual size passed to qemu-img create.";
        };

        memoryMiB = lib.mkOption {
          type = lib.types.ints.positive;
          default = 4096;
        };

        vcpus = lib.mkOption {
          type = lib.types.ints.positive;
          default = 2;
        };

        bridge = lib.mkOption {
          type = lib.types.str;
          default = "br0";
          description = "Name of the LAN bridge the VM attaches to.";
        };

        lanInterface = lib.mkOption {
          type = lib.types.str;
          description = ''
            Physical NIC enslaved by the bridge. The host's IP moves from this
            interface onto the bridge, so the first rebuild after enabling the
            module briefly drops the LAN link.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        # ---- Networking: enslave the LAN NIC into a bridge --------------
        networking.bridges.${bridgeName}.interfaces = [ lanInterface ];
        # The physical NIC must NOT have its own DHCP client once it's a
        # bridge member; DHCP runs on the bridge instead.
        networking.interfaces.${lanInterface}.useDHCP = false;
        networking.interfaces.${bridgeName}.useDHCP = true;

        # ---- libvirt + virtiofs --------------------------------------------
        virtualisation.libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            ovmf.enable = true;
            vhostUserPackages = [ pkgs.virtiofsd ];
          };
        };

        # ---- One-shot: create the qcow2 if missing -------------------------
        systemd.tmpfiles.rules = [
          "d ${builtins.dirOf (toString cfg.diskPath)} 0750 root libvirtd - -"
        ];

        systemd.services.hermes-vm-disk = {
          description = "Create hermes-vm qcow2 disk if missing";
          wantedBy = [ "multi-user.target" ];
          before = [ "libvirtd.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [ pkgs.qemu_kvm ];
          script = ''
            set -euo pipefail
            if [ ! -f "${toString diskPath}" ]; then
              install -d -m 0750 -o root -g libvirtd "$(dirname "${toString diskPath}")"
              qemu-img create -f qcow2 -o preallocation=metadata "${toString diskPath}" "${diskSize}"
              chown root:libvirtd "${toString diskPath}"
              chmod 0660 "${toString diskPath}"
              echo "Created blank qcow2 at ${toString diskPath}; install with hvm-install." >&2
            fi
          '';
        };

        # ---- One-shot: define / refresh the libvirt domain -----------------
        # virsh define is idempotent: re-defining an existing domain just
        # updates the XML, it does NOT restart a running guest. We `define`
        # on every activation so XML edits take effect, but only `start`
        # if the disk image actually has an OS on it (size > 1 MiB above
        # the metadata-preallocation floor).
        systemd.services.hermes-vm-domain = {
          description = "Define hermes-vm libvirt domain";
          wantedBy = [ "multi-user.target" ];
          after = [
            "libvirtd.service"
            "hermes-vm-disk.service"
          ];
          requires = [
            "libvirtd.service"
            "hermes-vm-disk.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [
            pkgs.libvirt
            pkgs.coreutils
          ];
          script = ''
            set -euo pipefail
            virsh --connect qemu:///system define ${domainXml}
            virsh --connect qemu:///system autostart ${vmName} || true

            # Heuristic: skip auto-start while the disk is still empty so we
            # don't boot a brick. hvm-install flips this once an OS is on it.
            if [ -f /var/lib/hermes-vm/.installed ]; then
              if ! virsh --connect qemu:///system domstate ${vmName} | grep -q running; then
                virsh --connect qemu:///system start ${vmName} || true
              fi
            else
              echo "hermes-vm disk not yet installed; skipping auto-start." >&2
              echo "Run: hvm-install <path-to-seed.qcow2>" >&2
            fi
          '';
        };

        # ---- Helpers in PATH -----------------------------------------------
        environment.systemPackages = [
          hvm-snap
          (pkgs.writeShellApplication {
            name = "hvm-install";
            runtimeInputs = with pkgs; [
              coreutils
              qemu_kvm
              libvirt
            ];
            text = ''
              set -euo pipefail
              if [ "$#" -ne 1 ]; then
                echo "usage: hvm-install <path-to-seed.qcow2>" >&2
                exit 64
              fi
              src="$1"
              echo "Stopping ${vmName} (if running)..." >&2
              virsh --connect qemu:///system destroy ${vmName} >/dev/null 2>&1 || true
              echo "Copying $src -> ${toString diskPath}" >&2
              # Convert in place so any source format works (qcow2/raw/vmdk).
              qemu-img convert -O qcow2 "$src" "${toString diskPath}".new
              mv "${toString diskPath}".new "${toString diskPath}"
              chown root:libvirtd "${toString diskPath}"
              chmod 0660 "${toString diskPath}"
              install -d -m 0750 -o root -g libvirtd /var/lib/hermes-vm
              touch /var/lib/hermes-vm/.installed
              echo "Installed. Start with: virsh --connect qemu:///system start ${vmName}" >&2
            '';
          })
        ];
      };
    };
}
