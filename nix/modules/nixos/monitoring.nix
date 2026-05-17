{
  inputs,
  ...
}:
{
  flake.modules.nixos.monitoring =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        services.prometheus = {
          enable = true;
          listenAddress = "127.0.0.1";
          port = 9090;
          scrapeConfigs = [
            {
              job_name = "node";
              static_configs = [
                {
                  targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
                }
              ];
            }
            {
              job_name = "prometheus";
              static_configs = [
                {
                  targets = [ "127.0.0.1:${toString config.services.prometheus.port}" ];
                }
              ];
            }
          ];
        };

        services.prometheus.exporters.node = {
          enable = true;
          listenAddress = "127.0.0.1";
          port = 9100;
          enabledCollectors = [ "textfile" ];
          extraFlags = [
            "--collector.textfile.directory=/var/lib/prometheus-node-exporter-textfiles"
          ];
        };

        services.grafana = {
          enable = true;
          settings = {
            server = {
              http_addr = "127.0.0.1";
              http_port = 3090;
            };
            security = {
              admin_user = "admin";
              admin_password = "admin";
              secret_key = "daF7ALq9IIhNt6UOhwqsoOkCkrq9ImiZ";
            };
          };
          provision = {
            enable = true;
            datasources.settings = {
              apiVersion = 1;
              datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  access = "proxy";
                  url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                  isDefault = true;
                }
              ];
            };
            dashboards.settings = {
              apiVersion = 1;
              providers = [
                {
                  name = "default";
                  options.path = "/etc/grafana/dashboards";
                }
              ];
            };
          };
        };

        environment.etc."grafana/dashboards/restic.json".source = ./restic-dashboard.json;
      };
    };
}
