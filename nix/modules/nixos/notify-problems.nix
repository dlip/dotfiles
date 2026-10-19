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
      config.sops.secrets.notify = { };
      config.systemd.services."notify-problems@" = {
        enable = true;
        description = "Alert for %i via Telegram";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Group = "systemd-journal";
        };

        environment.SERVICE = "%i";
        script = ''
          tmpfile=$(mktemp)
          trap 'rm -f "$tmpfile"' EXIT
          {
            printf '%s: %s Error\n\n' "$HOSTNAME" "$SERVICE"
            systemctl status --full "$SERVICE" 2>&1 || true
          } > "$tmpfile"
          ${pkgs.notify}/bin/notify -bulk -data "$tmpfile" \
            -provider telegram -provider-config ${config.sops.secrets.notify.path}
        '';
      };
    };
}
