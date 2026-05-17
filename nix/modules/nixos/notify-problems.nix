{
  inputs,
  ...
}:
{
  flake.modules.nixos.notify-problems =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      config.sops.secrets.gotify = { };
      config.systemd.services."notify-problems@" = {
        enable = true;
        description = "Alert for %i via gotify";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Group = "systemd-journal";
        };

        environment.SERVICE = "%i";
        script = ''
          GOTIFY_TOKEN=$(cat ${config.sops.secrets.gotify.path})
          ${pkgs.gotify-cli}/bin/gotify push \
            --url "http://127.0.0.1:8080" \
            --token "$GOTIFY_TOKEN" \
            --title "$HOSTNAME: $SERVICE Error" \
            --priority 5 \
            <<< "$(systemctl status --full "$SERVICE" 2>&1)"
        '';
      };
    };
}
