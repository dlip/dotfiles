{
  ...
}:
{
  flake.modules.nixos.tududi =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    let
      cfg = config.services.tududi;
    in
    {
      options.services.tududi = {
        enable = lib.mkEnableOption "tududi task management service";

        image = lib.mkOption {
          type = lib.types.str;
          default = "chrisvel/tududi:latest";
          description = "Docker image to use for tududi.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 3002;
          description = "Port to expose tududi on.";
        };

        userEmail = lib.mkOption {
          type = lib.types.str;
          default = "admin@tududi.local";
          description = "Admin user email for tududi.";
        };

        userPasswordFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to a file containing the admin password.";
        };

        sessionSecretFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to a file containing the session secret.";
        };

        extraEnv = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Additional environment variables for tududi.";
        };

        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/tududi";
          description = "Directory to store tududi data (database, uploads).";
        };

        allowedOrigins = lib.mkOption {
          type = lib.types.str;
          default = "http://localhost:3002";
          description = "Allowed origins for CORS.";
        };

        trustProxy = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to trust reverse proxy headers.";
        };
      };

      config = lib.mkIf cfg.enable {
        virtualisation.oci-containers.containers.tududi = {
          image = cfg.image;
          ports = [ "127.0.0.1:${toString cfg.port}:3002" ];
          environment = {
            TUDUDI_USER_EMAIL = cfg.userEmail;
            TUDUDI_ALLOWED_ORIGINS = cfg.allowedOrigins;
            TUDUDI_TRUST_PROXY = if cfg.trustProxy then "true" else "false";
            TUDUDI_UPLOAD_PATH = "/app/backend/uploads";
            NODE_ENV = "production";
            DB_FILE = "db/production.sqlite3";
          } // cfg.extraEnv;
          environmentFiles = [
            cfg.sessionSecretFile
            cfg.userPasswordFile
          ];
          volumes = [
            "${cfg.dataDir}/db:/app/backend/db"
            "${cfg.dataDir}/uploads:/app/backend/uploads"
          ];
          extraOptions = [ ];
        };
      };
    };
}
