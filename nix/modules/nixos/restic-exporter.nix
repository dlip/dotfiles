{
  inputs,
  ...
}:
{
  flake.modules.nixos.restic-exporter =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.restic.backups.dex.backupCleanupCommand = ''
        METRICS_DIR="/var/lib/prometheus-node-exporter-textfiles"
        TMPFILE=$(mktemp)

        cleanup() { rm -f "$TMPFILE"; }
        trap cleanup EXIT

        echo '# HELP restic_backup_success Whether restic stats command succeeded (1=success, 0=failure)' >> "$TMPFILE"
        echo '# TYPE restic_backup_success gauge' >> "$TMPFILE"
        echo '# HELP restic_repository_size_bytes Total size of files in the restic repository' >> "$TMPFILE"
        echo '# TYPE restic_repository_size_bytes gauge' >> "$TMPFILE"
        echo '# HELP restic_snapshots_total Total number of restic snapshots' >> "$TMPFILE"
        echo '# TYPE restic_snapshots_total gauge' >> "$TMPFILE"
        echo '# HELP restic_total_file_count Total number of files backed up in restic repository' >> "$TMPFILE"
        echo '# TYPE restic_total_file_count gauge' >> "$TMPFILE"
        echo '# HELP restic_last_backup_timestamp_ms Unix timestamp (ms) of the latest restic snapshot' >> "$TMPFILE"
        echo '# TYPE restic_last_backup_timestamp_ms gauge' >> "$TMPFILE"

        if STATS=$(${lib.getExe pkgs.restic} stats --json 2>/dev/null); then
          echo "restic_backup_success 1" >> "$TMPFILE"
          echo "restic_repository_size_bytes $(echo "$STATS" | ${lib.getExe pkgs.jq} '.total_size // 0')" >> "$TMPFILE"
          echo "restic_snapshots_total $(echo "$STATS" | ${lib.getExe pkgs.jq} '.snapshots_count // 0')" >> "$TMPFILE"
          echo "restic_total_file_count $(echo "$STATS" | ${lib.getExe pkgs.jq} '.total_file_count // 0')" >> "$TMPFILE"
        else
          echo "restic_backup_success 0" >> "$TMPFILE"
        fi

        if SNAPSHOTS=$(${lib.getExe pkgs.restic} snapshots --json 2>/dev/null); then
          LATEST=$(echo "$SNAPSHOTS" | ${lib.getExe pkgs.jq} -r 'max_by(.time).time // empty' 2>/dev/null)
          if [ -n "$LATEST" ]; then
            TIMESTAMP=$(date -d "$LATEST" +%s 2>/dev/null || echo 0)
            echo "restic_last_backup_timestamp_ms $((TIMESTAMP * 1000))" >> "$TMPFILE"
          fi
        fi

        mkdir -p "$METRICS_DIR"
        mv "$TMPFILE" "$METRICS_DIR/restic.prom"
        chmod 644 "$METRICS_DIR/restic.prom"
      '';

      systemd.services.restic-backups-dex = {
        serviceConfig.TimeoutStopSec = "10min";
        unitConfig.OnFailure = "notify-problems@%i.service";
      };
    };
}
