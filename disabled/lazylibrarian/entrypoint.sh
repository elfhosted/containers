#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

#shellcheck disable=SC2086
cd /config # This ensures that our logs go to the writeable /config volume
exec \
    /usr/bin/python3 /app/lazylibrarian/LazyLibrarian.py \
    --datadir /config --nolaunch