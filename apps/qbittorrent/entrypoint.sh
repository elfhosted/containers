#!/usr/bin/env bash

set -e

#shellcheck disable=SC1091
source "/scripts/umask.sh"
source "/scripts/vpn.sh"
source "/scripts/elfscript.sh"

# Make logs go to stdout for Kubernetes
qbtLogFile=/config/qBittorrent/logs/qbittorrent.log
if [ -f "$qbtLogFile" ] 
then
    rm $qbtLogFile
fi
mkdir -p /config/qBittorrent/logs/
ln -sf /proc/self/fd/1 "$qbtLogFile"

# If we have been given a port by pia/gluetun, insert it into the config before starting
# Apply the port
if [[ ! -z "$PORT_FILE" ]]; then

    # Wait until a file is found which is less than 5 min old
    until (find $PORT_FILE -mmin 5); do
        echo waiting for port-forward details...
        sleep 5s
    done

    sed -i  "s/Connection\\\PortRangeMin=.*/Connection\\\PortRangeMin=$(cat $PORT_FILE)/" /config/qBittorrent/qBittorrent.conf
    sed -i  "s/Session\\\Port=.*/Session\\\Port=$(cat $PORT_FILE)/" /config/qBittorrent/qBittorrent.conf
fi 

exec /usr/bin/qbittorrent-nox
