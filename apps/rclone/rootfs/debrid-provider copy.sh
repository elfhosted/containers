#!/bin/ash

/usr/bin/rclone serve webdav \
    --config /config/rclone-debrid-provider.conf \
    --addr :9999 \
    --max-header-bytes=8192 \
    --no-modtime \
    --vfs-read-chunk-size=10M \
    --vfs-read-chunk-size-limit=10M \
    --dir-cache-time 10s \
    --multi-thread-streams=0 \
    --cutoff-mode=cautious \
    --vfs-cache-mode writes \
    --buffer-size=0 \
    -v \
    debrid-provider:

