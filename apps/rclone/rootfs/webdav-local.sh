# run this to serve our mounts internally via webdav from /mount
#!/bin/ash

/usr/bin/rclone serve webdav \
    --addr :5575 \
    --max-header-bytes=8192 \
    --vfs-read-chunk-size=10M \
    --vfs-read-chunk-size-limit=10M \
    --stats 60s \
    --copy-links \
    -v \
    /mount
