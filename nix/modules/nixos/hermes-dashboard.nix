{
  ...
}:
{
  flake.modules.nixos.hermes-dashboard =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    let
      cfg = config.services.hermes-dashboard;
    in
    {
      options.services.hermes-dashboard = {
        enable = lib.mkEnableOption "the Hermes Agent web dashboard";

        port = lib.mkOption {
          type = lib.types.port;
          default = 9119;
          description = "Port for the dashboard to listen on.";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "0.0.0.0";
          description = "Host address for the dashboard to bind to.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open the configured port in the firewall.";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "hermes";
          description = "User to run the dashboard service as.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = config.services.hermes-agent.enable;
            message = "services.hermes-dashboard requires services.hermes-agent.enable = true";
          }
        ];

        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

        systemd.services.hermes-dashboard = {
          description = "Hermes Agent Web Dashboard";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          environment = {
            HERMES_HOME = "/var/lib/hermes/.hermes";
          };

          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.user;
            ExecStart = "${config.services.hermes-agent.package}/bin/hermes dashboard --host ${cfg.host} --port ${toString cfg.port} --insecure --no-open --tui";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
    };
}

