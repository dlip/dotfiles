# hermes-vm setup

Stage 1 of the hermes-agent VM on `dex`. See the conversation around
[modules/nixos/hermes-vm-host.nix](./modules/nixos/hermes-vm-host.nix) and
[modules/hermes-vm-seed.nix](./modules/hermes-vm-seed.nix) for the design
rationale.

## What this stack does

- `dex` boots a NixOS VM (libvirt + KVM, qcow2 disk, bridged onto the LAN).
- The VM owns its own `/etc/nixos` — no shared config with the dotfiles repo.
- The host bridges `enp0s31f6` into `br0` and routes everything (host IP,
  wireguard NAT, container egress) over the bridge.
- The host decrypts `hermes-env` via sops-nix and exports it into the VM
  read-only via virtiofs, so the agent's filesystem never touches the
  master age key.

## One-time setup

### 1. Edit the seed authorized_keys

Open [modules/hermes-vm-seed.nix](./modules/hermes-vm-seed.nix) and paste
your ssh public key into both `users.users.root.openssh.authorizedKeys.keys`
and `users.users.dane.openssh.authorizedKeys.keys`. Without this you can't
reach the VM after first boot.

### 2. First rebuild on dex (run on the local console, not over ssh)

This activation enslaves `enp0s31f6` into `br0`. The link will drop
momentarily while DHCP re-runs on the bridge — the router should hand the
bridge the same lease because the bridge inherits the NIC's MAC, but you
don't want to find out remotely if it doesn't.

```sh
sudo nixos-rebuild switch --flake ~/.#dex
```

Verify after it comes back up:

```sh
ip -br link show br0
ip -br addr show br0
ping -c 1 1.1.1.1
sudo virsh --connect qemu:///system list --all   # hermes-agent should appear, shut off
```

### 3. Build the seed qcow2

```sh
nix build ~/.#hermes-vm-seed
ls -lh ./result/nixos.qcow2
```

The result is a sparse qcow2; copy it to dex if you built it elsewhere.

### 4. Flash the seed into the VM disk

```sh
sudo hvm-install ./result/nixos.qcow2
```

`hvm-install` stops the VM if running, `qemu-img convert`s the seed over
the existing qcow2 at `/mnt/services/hermes-vm/disk.qcow2`, fixes
ownership, and marks the disk installed so subsequent boots will
auto-start.

### 5. Boot the VM

```sh
sudo virsh --connect qemu:///system start hermes-agent
sudo virsh --connect qemu:///system console hermes-agent  # serial; ^] to exit
```

After it reaches a login prompt, find its DHCP lease and ssh in:

```sh
sudo virsh --connect qemu:///system net-dhcp-leases default 2>/dev/null \
  || arp -an | grep $(sudo virsh --connect qemu:///system domifaddr hermes-agent | awk '/ipv4/ {print $4}' | cut -d/ -f1)
ssh root@<vm-ip>
```

Inside the VM, sanity-check the secret share and the agent service:

```sh
ls -l /run/secrets/hermes-env       # symlink into /run/host-secrets
systemctl status hermes-agent
journalctl -u hermes-agent -e
```

## Day-to-day

### Snapshots

```sh
sudo hvm-snap list
sudo hvm-snap create [tag]      # default tag: pre-YYYYMMDD-HHMMSS
sudo hvm-snap apply <tag>       # destroys + reverts + restarts the VM
sudo hvm-snap delete <tag>
```

These are qcow2-level snapshots — fast and cheap, but require the VM to
be off when you `apply`. For routine rollback inside the VM, prefer
`nixos-rebuild switch --rollback`; reach for `hvm-snap apply` only when
NixOS itself is unbootable.

### Updating the seed

The seed is only used for first install. After flashing, the VM diverges
and is updated from inside via `nixos-rebuild`. If you need to rebuild
from a fresh seed (e.g. after wiping the disk), repeat steps 3–5.

### Pruning state on dex

```sh
sudo virsh --connect qemu:///system destroy hermes-agent
sudo rm /mnt/services/hermes-vm/disk.qcow2
sudo rm /var/lib/hermes-vm/.installed
sudo systemctl restart hermes-vm-disk hermes-vm-domain
sudo hvm-install ./result/nixos.qcow2
```

## Architecture knobs

All exposed via `services.hermesVmHost` options in
[modules/nixos/hermes-vm-host.nix](./modules/nixos/hermes-vm-host.nix):

| Option           | Default                                      |
| ---------------- | -------------------------------------------- |
| `vmName`         | `hermes-agent`                               |
| `diskPath`       | `/mnt/services/hermes-vm/disk.qcow2`         |
| `diskSize`       | `32G`                                        |
| `memoryMiB`      | `4096`                                       |
| `vcpus`          | `2`                                          |
| `bridge`         | `br0`                                        |
| `lanInterface`   | (required, set to `enp0s31f6` on dex)        |

## What's deliberately NOT in Stage 1

- **No self-modification rights for the agent.** The seed boots a static
  config; expanding the agent's authority comes after the VM has proven
  stable. (Stage 4 in the original plan.)
- **No automatic pre-rebuild snapshots.** `hvm-snap` is manual for now.
- **No teardown of the nspawn `containers.hermes-agent` block on dex.**
  Both stacks coexist until you're confident the VM has replaced it; the
  nspawn instance is at
  [systems/dex/configuration.nix](./systems/dex/configuration.nix)
  around the `containers.hermes-agent` definition. Delete that block and
  the [systems/hermes-agent/configuration.nix](./systems/hermes-agent/configuration.nix)
  file once you cut over.

## Troubleshooting

**The VM isn't getting an IP.** Check the bridge: `ip -br link show br0`
should list `enp0s31f6` as a member and the bridge itself as `UP`. If
the bridge is up but no DHCP lease, your router probably isn't honouring
the new MAC; force-renew on the host (`sudo systemctl restart
systemd-networkd` or `dhcpcd`) and confirm it leases for both the host
and the VM.

**`virsh start` fails with "could not open disk image".** Check
ownership: the qcow2 must be `root:libvirtd` mode `0660`. The
`hermes-vm-disk` service sets this; if you replaced the file by hand
(`cp` or `dd` instead of `hvm-install`) you'll need to `chown` it.

**`/run/secrets/hermes-env` is missing inside the VM.** The virtiofs
mount unit failed. Check `systemctl status run-host\\x2dsecrets.mount`
inside the VM; on the host check that virtiofsd is running
(`systemctl status virtiofsd@hermes-agent` or look in `journalctl -u
libvirtd`).

**LAN connectivity to dex broke after the rebuild.** Roll back from the
console: `sudo nixos-rebuild switch --rollback`. The previous generation
restored the direct `enp0s31f6` config. Investigate the bridge issue
locally before re-applying.
