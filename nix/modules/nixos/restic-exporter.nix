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
        #!${pkgs.runtimeShell}
        set -euo pipefail
        METRICS_DIR="/var/lib/prometheus-node-exporter-textfiles"
        mkdir -p "$METRICS_DIR"
        TMPFILE=$(mktemp "$METRICS_DIR/.restic.XXXXXX")

        cleanup() { rm -f "$TMPFILE"; }
        trap cleanup EXIT

        echo '# HELP restic_backup_success Whether the backup service succeeded (1=success, 0=failure)' >> "$TMPFILE"
        echo '# TYPE restic_backup_success gauge' >> "$TMPFILE"
        echo '# HELP restic_repository_size_bytes Logical size of files in the latest restic snapshot' >> "$TMPFILE"
        echo '# TYPE restic_repository_size_bytes gauge' >> "$TMPFILE"
        echo '# HELP restic_snapshots_total Total number of restic snapshots' >> "$TMPFILE"
        echo '# TYPE restic_snapshots_total gauge' >> "$TMPFILE"
        echo '# HELP restic_total_file_count Number of files in the latest restic snapshot' >> "$TMPFILE"
        echo '# TYPE restic_total_file_count gauge' >> "$TMPFILE"
        echo '# HELP restic_last_backup_timestamp_ms Unix timestamp (ms) of the latest restic snapshot' >> "$TMPFILE"
        echo '# TYPE restic_last_backup_timestamp_ms gauge' >> "$TMPFILE"

        if [ "''${SERVICE_RESULT:-unknown}" = success ]; then
          echo "restic_backup_success 1" >> "$TMPFILE"
        else
          echo "restic_backup_success 0" >> "$TMPFILE"
        fi

        echo '# HELP restic_stats_success Whether latest-snapshot statistics were collected' >> "$TMPFILE"
        echo '# TYPE restic_stats_success gauge' >> "$TMPFILE"
        if STATS=$(${lib.getExe' pkgs.coreutils "timeout"} --kill-after=5s 30s ${lib.getExe pkgs.restic} stats --json latest 2>/dev/null) &&
          VALUES=$(echo "$STATS" | ${lib.getExe pkgs.jq} -er '
            select(type == "object") |
            [.total_size, .total_file_count] |
            select(all(.[]; type == "number" and . >= 0)) |
            @tsv'); then
          read -r SIZE FILES <<< "$VALUES"
          echo "restic_stats_success 1" >> "$TMPFILE"
          echo "restic_repository_size_bytes $SIZE" >> "$TMPFILE"
          echo "restic_total_file_count $FILES" >> "$TMPFILE"
        else
          echo "restic_stats_success 0" >> "$TMPFILE"
        fi

        if SNAPSHOTS=$(${lib.getExe' pkgs.coreutils "timeout"} --kill-after=5s 30s ${lib.getExe pkgs.restic} snapshots --json 2>/dev/null) &&
          COUNT=$(echo "$SNAPSHOTS" | ${lib.getExe pkgs.jq} -er 'select(type == "array") | length'); then
          echo "restic_snapshots_total $COUNT" >> "$TMPFILE"
          LATEST=$(echo "$SNAPSHOTS" | ${lib.getExe pkgs.jq} -r 'max_by(.time).time // empty')
          if [ -n "$LATEST" ] && TIMESTAMP=$(date -d "$LATEST" +%s 2>/dev/null); then
            echo "restic_last_backup_timestamp_ms $((TIMESTAMP * 1000))" >> "$TMPFILE"
          fi
        fi

        chmod 644 "$TMPFILE"
        mv "$TMPFILE" "$METRICS_DIR/restic.prom"
      '';

      systemd.services.restic-backups-dex = {
        serviceConfig.TimeoutStopSec = "10min";
        unitConfig.OnFailure = "notify-problems@%p.service";
      };
    };
}
