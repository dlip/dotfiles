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

  # https://github.com/NousResearch/hermes-agent/issues/12195
  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
      ln -sfn /run/current-system/sw/bin/bash /bin/bash
    '';
  };

  environment.systemPackages =
    with pkgs;
    groups.default
    ++ [
      go
      python3
      # Hermes can make a pr to add any extra packages it needs here
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
    package = self.inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      extraPythonPackages = with pkgs.stable; [ python312Packages.python-telegram-bot ];
    };
    settings = {
      model.default = "nvidia/nemotron-3-super-120b-a12b:free";
    };
  };

  system.stateVersion = "25.05";
}
