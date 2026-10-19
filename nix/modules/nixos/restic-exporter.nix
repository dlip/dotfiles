{ ... }:
{
  flake.modules.nixos.restic-exporter =
    { config, pkgs, ... }:
    let
      backup = config.services.restic.backups.dex;
      metricsDir = "/var/lib/prometheus-node-exporter-textfiles";
    in
    {
      services.restic.backups.dex.backupCleanupCommand = ''
        set -euo pipefail
        mkdir -p ${metricsDir}
        tmpfile=$(mktemp ${metricsDir}/.restic-backup.XXXXXX)
        trap 'rm -f "$tmpfile"' EXIT
        {
          echo '# HELP restic_backup_success Whether the last backup service succeeded'
          echo '# TYPE restic_backup_success gauge'
          if [ "''${SERVICE_RESULT:-unknown}" = success ]; then
            echo 'restic_backup_success 1'
          else
            echo 'restic_backup_success 0'
          fi
        } > "$tmpfile"
        chmod 644 "$tmpfile"
        mv "$tmpfile" ${metricsDir}/restic-backup.prom
        systemctl start --no-block restic-metrics.service
      '';

      systemd.services.restic-metrics = {
        description = "Collect Restic snapshot and directory size metrics";
        after = [ "local-fs.target" ];
        unitConfig.RequiresMountsFor = [ backup.repository ];
        path = [
          pkgs.restic
          pkgs.coreutils
        ];
        environment = {
          RESTIC_REPOSITORY = backup.repository;
          RESTIC_PASSWORD_FILE = backup.passwordFile;
          RESTIC_CACHE_DIR = "/var/cache/restic-metrics";
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.python3}/bin/python3 ${./restic-metrics.py} ${metricsDir}/restic.prom";
          CacheDirectory = "restic-metrics";
          TimeoutStartSec = "10min";
          UMask = "0022";
          Nice = 10;
          IOSchedulingClass = "idle";
        };
      };
      systemd.timers.restic-metrics = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = "1h";
        };
      };
      systemd.services.restic-backups-dex = {
        serviceConfig.TimeoutStopSec = "10min";
        unitConfig.OnFailure = "notify-problems@%p.service";
      };
    };
}
