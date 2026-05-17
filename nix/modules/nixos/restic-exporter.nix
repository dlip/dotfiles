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
    let
      resticCfg = config.services.restic.backups.dex;
    in
    {
      config = lib.mkIf (config.services.restic.backups ? dex) {
        systemd.services.restic-metrics = {
          description = "Collect restic backup metrics for Prometheus";
          after = [ "network.target" ];
          wants = [ "restic-backups-dex.service" ];
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
          environment = {
            RESTIC_REPOSITORY = resticCfg.repository;
            RESTIC_PASSWORD_FILE = resticCfg.passwordFile;
          };
          script = ''
                        METRICS_DIR="/var/lib/prometheus-node-exporter-textfiles"
                        TMPFILE=$(mktemp)

                        cleanup() { rm -f "$TMPFILE"; }
                        trap cleanup EXIT

                        cat > "$TMPFILE" << 'EOF'
            # HELP restic_backup_success Whether restic stats collection succeeded (1=success, 0=failure)
            # TYPE restic_backup_success gauge
            # HELP restic_repository_size_bytes Total size of files in the restic repository
            # TYPE restic_repository_size_bytes gauge
            # HELP restic_snapshots_total Total number of restic snapshots
            # TYPE restic_snapshots_total gauge
            # HELP restic_total_file_count Total number of files backed up in restic repository
            # TYPE restic_total_file_count gauge
            # HELP restic_last_backup_timestamp_seconds Unix timestamp of the latest restic snapshot
            # TYPE restic_last_backup_timestamp_seconds gauge
            EOF

                        if STATS=$(${lib.getExe pkgs.restic} stats --json 2>/dev/null); then
                          echo "restic_backup_success 1" >> "$TMPFILE"
                          echo "restic_repository_size_bytes $(echo "$STATS" | ${lib.getExe pkgs.jq} '.total_size // 0')" >> "$TMPFILE"
                          echo "restic_snapshots_total $(echo "$STATS" | ${lib.getExe pkgs.jq} '.total_snapshots // 0')" >> "$TMPFILE"
                          echo "restic_total_file_count $(echo "$STATS" | ${lib.getExe pkgs.jq} '.total_file_count // 0')" >> "$TMPFILE"
                        else
                          echo "restic_backup_success 0" >> "$TMPFILE"
                        fi

                        if SNAPSHOTS=$(${lib.getExe pkgs.restic} snapshots --json --latest 2 2>/dev/null); then
                          LATEST=$(echo "$SNAPSHOTS" | ${lib.getExe pkgs.jq} -r '.[0].time // empty' 2>/dev/null)
                          if [ -n "$LATEST" ]; then
                            TIMESTAMP=$(date -d "$LATEST" +%s 2>/dev/null || echo 0)
                            echo "restic_last_backup_timestamp_seconds $TIMESTAMP" >> "$TMPFILE"
                          fi
                        fi

            mkdir -p "$METRICS_DIR"
            mv "$TMPFILE" "$METRICS_DIR/restic.prom"
            chmod 644 "$METRICS_DIR/restic.prom"
          '';
        };

        systemd.timers.restic-metrics = {
          description = "Collect restic metrics hourly";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "hourly";
            Persistent = true;
          };
        };
      };
    };
}
