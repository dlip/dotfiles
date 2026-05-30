{
  ...
}:
{
  flake.modules.nixos.hermes-webui =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    let
      cfg = config.services.hermes-webui;

      hermesWebuiSrc = pkgs.fetchFromGitHub {
        owner = "nesquena";
        repo = "hermes-webui";
        rev = "master";
        sha256 = "1ipn3j48k385sdzw6b89yk400142pvbaby6b4yylvdrd1cp6xlx7";
      };

      # Extract the Hermes Agent Python interpreter from the hermes wrapper script.
      # The hermes binary is a bash wrapper that exports HERMES_PYTHON pointing to
      # the agent's venv Python (which has all agent modules + pyyaml available).
      webuiStartScript = pkgs.writeShellScript "hermes-webui-start" ''
        HERMES_PYTHON=$(grep -oP "HERMES_PYTHON='\K[^']+" ${config.services.hermes-agent.package}/bin/hermes)

        export HERMES_WEBUI_HOST="${cfg.host}"
        export HERMES_WEBUI_PORT="${toString cfg.port}"
        export HERMES_WEBUI_STATE_DIR="/var/lib/hermes/webui"
        export HERMES_HOME="/var/lib/hermes/.hermes"

        mkdir -p /var/lib/hermes/webui

        exec "$HERMES_PYTHON" ${hermesWebuiSrc}/server.py
      '';
    in
    {
      options.services.hermes-webui = {
        enable = lib.mkEnableOption "the Hermes Web UI — browser interface for Hermes Agent from nesquena/hermes-webui";

        port = lib.mkOption {
          type = lib.types.port;
          default = 8787;
          description = "Port for the Web UI to listen on.";
        };

        host = lib.mkOption {
          type = lib.types.str;
          default = "0.0.0.0";
          description = "Host address for the Web UI to bind to.";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "hermes";
          description = "user to run the web ui service as.";
        };
        group = lib.mkOption {
          type = lib.types.str;
          default = "users";
          description = "Group to run the web ui service as.";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = config.services.hermes-agent.enable;
            message = "services.hermes-webui requires services.hermes-agent.enable = true";
          }
        ];

        systemd.services.hermes-webui = {
          description = "Hermes Web UI — Browser Interface";
          documentation = [ "https://github.com/nesquena/hermes-webui" ];
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            ExecStart = "${webuiStartScript}";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
    };
}
