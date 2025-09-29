{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
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
  systemd.user.services.waybar = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = [
        "graphical-session.target"
      ];
      After = "graphical-session.target";
      Requisite = "graphical-session.target";
    };

    Install = {
      WantedBy = [
        "niri.service"
      ];
    };

    Service = {
      ExecStart = ''${pkgs.waybar}/bin/waybar'';
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      KillMode = "mixed";
      Restart = "on-failure";
    };
  };
}
