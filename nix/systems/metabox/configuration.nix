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
    ++ [

    ];

  networking.wireless.enable = true;
  users.users.dane = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [ "wheel" ];
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
