{
  pkgs,
  config,
  ...
}:
{
  programs.niri = {
    enable = true;
  };
  programs.dankMaterialShell = {
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet /usr/bin/env --xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
        user = "greeter";
      };
    };
  };
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  environment.systemPackages = with pkgs; [
    xorg.xinit
    tuigreet
    swaylock
    file-roller
    adwaita-icon-theme # default gnome cursors
    waybar
    xwayland-satellite
    brightnessctl
    cliphist
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    fuzzel
    grimblast
    libnotify
    playerctl
    sway-contrib.grimshot
    swayidle
    udiskie
    networkmanagerapplet
    rofi
    rofimoji
    swaynotificationcenter
    hypridle
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
