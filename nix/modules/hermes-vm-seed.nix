{ self, inputs, ... }:
{
  # Seed image for the hermes-agent VM.
  #
  # Build with:
  #   nix build .#hermes-vm-seed
  # then flash into the host's qcow2:
  #   sudo hvm-install ./result/nixos.qcow2
  #
  # After first boot the seed's job is done: the agent owns its own
  # /etc/nixos and the OS evolves entirely inside the VM. The seed exists
  # only so the very first boot has sshd, networking, sops-nix, and the
  # hermes-agent service running with sane defaults.
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    {
      packages.hermes-vm-seed = inputs.nixos-generators.nixosGenerate {
        inherit system;
        format = "qcow";
        specialArgs = {
          inherit inputs;
          hostname = "hermes-vm";
        };
        modules = [
          inputs.hermes-agent.nixosModules.default
          (
            { config, lib, ... }:
            {
              networking = {
                hostName = "hermes-vm";
                useDHCP = lib.mkForce true;
                firewall.allowedTCPPorts = [ 22 ];
              };

              services.openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  PermitRootLogin = "prohibit-password";
                };
              };

              users.users.root.openssh.authorizedKeys.keys = [
                # TODO: paste your ssh public key here before building the
                # seed. Without this you can't reach the VM after first
                # boot. Pull from ~/.ssh/id_ed25519.pub on the box you'll
                # be administering from.
              ];

              users.users.dane = {
                isNormalUser = true;
                extraGroups = [ "wheel" ];
                openssh.authorizedKeys.keys = [
                  # TODO: same as above.
                ];
              };

              security.sudo.wheelNeedsPassword = false;

              # virtiofs share from the host carrying the sops-rendered
              # secret. The host module mounts /run/secrets read-only into
              # the guest as the virtiofs tag `hermes-secrets`.
              fileSystems."/run/host-secrets" = {
                device = "hermes-secrets";
                fsType = "virtiofs";
                options = [
                  "nofail"
                  "x-systemd.automount"
                ];
              };

              # Re-export the host's decrypted secret at the path the agent
              # expects. We deliberately don't run sops-nix inside the VM;
              # the host already decrypted it and we don't want a second
              # copy of the master key on a disk the agent can edit.
              systemd.tmpfiles.rules = [
                "L+ /run/secrets/hermes-env - - - - /run/host-secrets/hermes-env"
              ];

              services.hermes-agent = {
                enable = true;
                environmentFiles = [ "/run/secrets/hermes-env" ];
                addToSystemPackages = true;
                package = inputs.hermes-agent.packages.${system}.default.override {
                  extraPythonPackages = with pkgs; [ python312Packages.python-telegram-bot ];
                };
                settings = {
                  model.default = "minimax/minimax-m2.7";
                };
              };

              # Self-modification helpers preinstalled so the agent has
              # them on first boot.
              environment.systemPackages = with pkgs; [
                git
                vim
              ];

              # Same hardening as the nspawn version on dex. Flip
              # MemoryDenyWriteExecute on if you confirm hermes never JITs.
              systemd.services.hermes-agent.serviceConfig = {
                NoNewPrivileges = true;
                ProtectSystem = "strict";
                ProtectHome = true;
                PrivateTmp = true;
                PrivateDevices = true;
                ProtectKernelTunables = true;
                ProtectKernelModules = true;
                ProtectKernelLogs = true;
                ProtectControlGroups = true;
                ProtectClock = true;
                ProtectHostname = true;
                LockPersonality = true;
                RestrictRealtime = true;
                RestrictSUIDSGID = true;
                RestrictNamespaces = true;
                RestrictAddressFamilies = [
                  "AF_INET"
                  "AF_INET6"
                  "AF_UNIX"
                ];
                CapabilityBoundingSet = "";
                AmbientCapabilities = "";
                MemoryDenyWriteExecute = false;
              };

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              system.stateVersion = "25.05";
            }
          )
        ];
      };
    };
}
