{
  config,
  lib,
  pkgs,
  ...
}:

# Cut from https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/master/nixos/modules/services/system/dbus.nix

let
  cfg = config.dbus;
  dbus-start-bin = "dbus-start";
  dbus-start = pkgs.writeScriptBin dbus-start-bin ''
    #!${pkgs.runtimeShell}
    ${pkgs.dbus}/bin/dbus-daemon --session &
  '';
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    mkMerge
    types
    ;
in
{
  options.dbus = {
    enable = mkEnableOption ''
      Whether to start the D-Bus message bus daemon, which is
      required by many other system services and applications.
    '';

    packages = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = ''
        Packages whose D-Bus configuration files should be included in
        the configuration of the D-Bus system-wide or session-wide
        message bus.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.etc."dbus-1".source = pkgs.makeDBusConf.override {
        suidHelper = "/bin/false";
        serviceDirectories = cfg.packages;
      };
      environment.packages = [
        dbus-start
        pkgs.dbus
      ];

      build.activationAfter.dbus = ''
        DBUS_PID=$(${pkgs.procps}/bin/ps -a | ${pkgs.toybox}/bin/grep dbus || true)
        if [ -z "$DBUS_PID" ]; then
          $DRY_RUN_CMD ${dbus-start}/bin/${dbus-start-bin}
        fi
      '';
    }

  ]);
}
