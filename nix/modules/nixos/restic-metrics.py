"""Export latest-snapshot logical sizes without reading file contents."""

from collections import defaultdict
from datetime import datetime
import json
import os
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tempfile
import time


def restic(*args):
    return json.loads(subprocess.check_output(
        ["timeout", "--kill-after=5s", "60s", "restic", "--json", *args], text=True))


def collect():
    snapshots = restic("snapshots")
    lines = [
        "# HELP restic_snapshots_total Number of snapshots in the repository",
        "# TYPE restic_snapshots_total gauge",
        f"restic_snapshots_total {len(snapshots)}",
    ]
    if not snapshots:
        return lines
    latest = max(snapshots, key=lambda item: item["time"])
    timestamp = datetime.fromisoformat(latest["time"].replace("Z", "+00:00")).timestamp()
    sizes = defaultdict(int)
    total = count = 0
    command = ["timeout", "--kill-after=5s", "8m", "restic", "ls", "--json", latest["id"]]
    with subprocess.Popen(command, stdout=subprocess.PIPE, text=True) as process:
        for line in process.stdout:
            node = json.loads(line)
            if node.get("type") != "file":
                continue
            size = node["size"]
            if not isinstance(size, int) or size < 0:
                raise ValueError("Invalid file size from Restic")
            total += size
            count += 1
            for parent in PurePosixPath(node["path"]).parents:
                depth = len(parent.parts) - 1
                if 1 <= depth <= 4:
                    sizes[str(parent)] += size
        if process.wait():
            raise RuntimeError(f"restic ls exited with status {process.returncode}")
    for name, help_text, value in (
        ("restic_repository_size_bytes", "Logical size of the latest snapshot before compression and deduplication", total),
        ("restic_total_file_count", "Number of files in the latest snapshot", count),
        ("restic_last_backup_timestamp_ms", "Timestamp of the latest successful snapshot in milliseconds", int(timestamp * 1000)),
    ):
        lines.extend([f"# HELP {name} {help_text}", f"# TYPE {name} gauge", f"{name} {value}"])
    lines.extend([
        "# HELP restic_path_size_bytes Logical directory size including descendants in the latest snapshot",
        "# TYPE restic_path_size_bytes gauge",
    ])
    # Bound series count while retaining useful detail at each directory depth.
    for depth in range(1, 5):
        paths = ((path, size) for path, size in sizes.items()
                 if len(PurePosixPath(path).parts) - 1 == depth)
        for path, size in sorted(paths, key=lambda item: item[1], reverse=True)[:50]:
            label = path.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")
            lines.append(f'restic_path_size_bytes{{path="{label}",depth="{depth}"}} {size}')
    return lines


def main(destination):
    success = 1
    try:
        lines = collect()
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Restic metric collection failed: {error}", file=sys.stderr)
        lines = []
        success = 0
    lines.extend([
        "# HELP restic_stats_success Whether snapshot metric collection succeeded",
        "# TYPE restic_stats_success gauge",
        f"restic_stats_success {success}",
        "# HELP restic_metrics_collection_timestamp_seconds Time of the last collection attempt",
        "# TYPE restic_metrics_collection_timestamp_seconds gauge",
        f"restic_metrics_collection_timestamp_seconds {int(time.time())}",
    ])
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=destination.parent, prefix=".restic-", delete=False) as stream:
            temporary = Path(stream.name)
            stream.write("\n".join(lines) + "\n")
        temporary.chmod(0o644)
        temporary.replace(destination)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main(Path(sys.argv[1])))
