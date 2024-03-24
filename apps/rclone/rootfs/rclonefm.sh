#!/bin/ash

/usr/bin/rclone rcd \
    --config=/config/rclone.conf \
    --rc-web-gui \
    --rc-addr=0.0.0.0:5573 \
    --rc-web-gui-no-open-browser \
    --rc-no-auth \
    --transfers=1 \
    --links \
    --multi-thread-streams=1 \
    /var/lib/rclonefm