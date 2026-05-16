top@{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
    self.modules.nixos.common
    self.modules.nixos.xfce
  ];

  environment.systemPackages =
    with pkgs;
    groups.gui
    ++ groups.gaming
    ++ [

    ];

  networking.wireless.enable = true;
  users.users.dane = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" ];
  };

  users.users.gaming = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ ];
  };

  services.openssh.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  hardware.steam-hardware.enable = true;

  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = [
    "nvidia"
  ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    # nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  hardware.nvidia.prime = {
    # sync.enable = true;
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # services.ollama = {
  #   enable = true;
  #   package = pkgs.ollama-cuda;
  #   host = "0.0.0.0";
  #   openFirewall = true;
  # };
  system.stateVersion = "25.05";
}
