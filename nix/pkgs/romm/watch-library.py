from pathlib import Path

from watchfiles import Change, DefaultFilter, watch

from config import LIBRARY_BASE_PATH
from utils.filesystem import TEMP_FILE_PREFIX
from watcher import EventType, process_changes

default_filter = DefaultFilter()


def library_filter(change, path):
    return (
        change in (Change.added, Change.deleted)
        and default_filter(change, path)
        and not any(part.startswith(TEMP_FILE_PREFIX) for part in Path(path).parts)
    )


if __name__ == "__main__":
    for changes in watch(LIBRARY_BASE_PATH, watch_filter=library_filter):
        process_changes([(EventType(change.name), path) for change, path in changes])
