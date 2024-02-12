#!/bin/ash

/usr/bin/rclone serve webdav \
    --config /rlcone-alldebrid.conf \
    --addr :9999 \
    --max-header-bytes=8192 \
    --no-modtime \
    --vfs-read-chunk-size=10M \
    --vfs-read-chunk-size-limit=10M \
    -v \
    alldebrid:

