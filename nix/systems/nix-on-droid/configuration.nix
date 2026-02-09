{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./dbus.nix ];
  dbus.enable = true;
  # Simply install just the packages
  environment.packages =
    pkgs.groups.default
    ++ (with pkgs; [
      i3
      i3status
      nixgl.auto.nixGLDefault
      xfce.xfce4-session
      xinit
      xfce.xfce4-panel
      xfce.xfdesktop
      kitty
      anki
    ]);

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  #time.timeZone = "Europe/Berlin";
}
