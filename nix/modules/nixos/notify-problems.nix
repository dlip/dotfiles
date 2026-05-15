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
      config.sops.secrets.notify = {
        sopsFile = ../../systems/common/secrets/secrets.yaml;
      };
      config.systemd.services."notify-problems@" = {
        enable = true;
        description = "Alert email for %i to user";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Group = "systemd-journal";
        };

        environment.SERVICE = "%i";
        script = ''
          tmpfile=$(mktemp /tmp/notify.XXXXXX)
          echo "
          $HOSTNAME: $SERVICE Error:
          $(systemctl status --full "$SERVICE")
          " > "$tmpfile"
          ${pkgs.notify}/bin/notify -bulk -data "$tmpfile" -provider-config ${config.sops.secrets.notify.path}
          rm "$tmpfile"
        '';
      };
    };
}
