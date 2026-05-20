{ self, inputs, ... }:
{
  pkgs,
  config,
  ...
}:
{
  imports = [
    self.inputs.hermes-agent.nixosModules.default
  ];

  # Mirror the host's nix experimental-features so any agent-driven nix
  # invocations behave identically to the rest of the dotfiles.
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Public DNS (independent of the host's resolver) so the container can be
  # reasoned about in isolation.
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  # The container has its own firewall. Disabled because the only inbound
  # consumer is the host (over the private veth) and we don't currently
  # expose any agent-side port; flip on + open ports if that changes.
  networking.firewall.enable = false;

  # The decrypted env file is bind-mounted in from the host's sops-rendered
  # path. See `bindMounts` in dex/configuration.nix.
  services.hermes-agent = {
    enable = true;
    environmentFiles = [ "/run/secrets/hermes-env" ];
    # Useful inside the container shell (`nixos-container root-login
    # hermes-agent`); the host doesn't need it because the agent runs here.
    addToSystemPackages = true;
    package =
      self.inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override
        {
          extraPythonPackages = with pkgs.stable; [ python312Packages.python-telegram-bot ];
        };
    settings = {
      model.default = "minimax/minimax-m2.7";
    };
  };

  # Defense in depth: even though the container already provides namespace
  # isolation, harden the unit itself so a compromised tool call has the
  # smallest possible blast radius inside the container.
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
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
    # Many Python LLM stacks JIT/load shared objects at runtime, so leaving
    # MemoryDenyWriteExecute off by default. Flip it on if you confirm the
    # agent never needs W^X.
    MemoryDenyWriteExecute = false;
  };

  system.stateVersion = "25.05";
}
