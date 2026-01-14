{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];
  programs.niri = {
    enable = true;
  };
  services.noctalia-shell.enable = true;
  # programs.dank-material-shell = {
  #   enable = true;
  #   systemd.enable = true;
  # };
  #
  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri"; # Or "hyprland" or "sway"
    configHome = "/home/dane";
  };
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.tuigreet}/bin/tuigreet /usr/bin/env --xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
  #       user = "greeter";
  #     };
  #   };
  # };
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
  environment.systemPackages = with pkgs; [

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    adwaita-icon-theme # default gnome cursors
    brightnessctl
    cliphist
    file-roller
    fuzzel
    grim
    hypridle
    libappindicator-gtk3
    libnotify
    networkmanagerapplet
    playerctl
    rofi
    rofimoji
    slurp
    sway-contrib.grimshot
    swayidle
    swaylock
    swaynotificationcenter
    # tuigreet
    udiskie
    waybar
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    xorg.xinit
    xwayland-satellite
  ];
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  i18n.inputMethod.fcitx5.waylandFrontend = true;
}
