#!/bin/ash

/usr/bin/rclone serve webdav \
    --config /config/rclone-debrid-provider.conf \
    --addr :9999 \
    --max-header-bytes=8192 \
    --no-modtime \
    --vfs-read-chunk-size=10M \
    --vfs-read-chunk-size-limit=100M \
    --dir-cache-time 60s \
    --multi-thread-streams=4 \
    --cutoff-mode=soft \
    --vfs-cache-mode writes \
    --buffer-size=32M \
    -vv \
    debrid-provider:

