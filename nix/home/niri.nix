{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    waybar
    xwayland-satellite
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
