{
  pkgs,
  ...
}:
{
  programs.niri = {
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --cmd ${pkgs.niri}/bin/niri-session";
      };
    };
  };
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  environment.systemPackages = with pkgs; [
    swaylock
    file-roller
    adwaita-icon-theme # default gnome cursors
  ];
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  i18n.inputMethod.fcitx5.waylandFrontend = true;
}
