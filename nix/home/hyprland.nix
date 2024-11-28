{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    brightnessctl
    cliphist
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    fuzzel
    grimblast
    hypridle
    hyprlock
    hyprpaper
    libnotify
    playerctl
    sway-contrib.grimshot
    swayidle
    udiskie
    networkmanagerapplet
    rofimoji
    waybar
    swaynotificationcenter
  ];
}
