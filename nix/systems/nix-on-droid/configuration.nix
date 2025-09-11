{
  config,
  lib,
  pkgs,
  ...
}:
let
  tools = pkgs.callPackage ./tools.nix {
  };
in
{

  imports = [ ./dbus.nix ];
  dbus.enable = true;
  # Simply install just the packages
  environment.packages =
    with pkgs;
    [
      # User-facing stuff that you really really want to have
      vim # or some other editor, e.g. nano or neovim
      i3
      i3status
      nixgl.auto.nixGLDefault
      xfce.xfce4-session
      xorg.xinit
      xfce.xfce4-panel
      xfce.xfdesktop
      kitty
      anki

      # Some common stuff that people expect to have
      #diffutils
      #findutils
      #utillinux
      #tzdata
      #hostname
      #man
      #gnugrep
      #gnupg
      #gnused
      #gnutar
      #bzip2
      #gzip
      #xz
      #zip
      #unzip
    ]
    ++ tools;

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "22.11";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  user.shell = "/etc/profiles/per-user/nix-on-droid/bin/zsh";
  # Set your time zone
  time.timeZone = "Australia/Sydney";
}
