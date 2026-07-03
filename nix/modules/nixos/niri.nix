{
  inputs,
  ...
}:
{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      imports = [
        # DankMaterialShell replaced by Noctalia v5 (spawned from the niri
        # config's spawn-at-startup). DMS module/greeter left disabled below.
        # inputs.dms.nixosModules.dank-material-shell
        # inputs.dms.nixosModules.greeter
      ];
      programs.niri = {
        enable = true;
      };
      # DankMaterialShell (previous shell) - disabled in favour of Noctalia.
      # programs.dank-material-shell = {
      #   enable = true;
      #   systemd.enable = true;
      # };
      environment.sessionVariables = {
        QS_DISABLE_CRASH_HANDLER = "1";
      };

      # environment.sessionVariables = {
      #   DMS_MODAL_LAYER = "overlay";
      # };

      # Login via greetd + tuigreet, launching niri-session.
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --sessions /run/current-system/sw/share/wayland-sessions --remember --remember-session --cmd niri-session";
            user = "greeter";
          };
        };
      };
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
        tuigreet
        udiskie
        waybar
        wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
        xinit
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
    };
}
