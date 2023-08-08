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

# If we have a tun0 or a wg0 interface, then configure qbit to use that exclusively
if $(ip link list | grep -q wg0); then
    # Insist on tun0
    sed -i  "s/Session\\\Interface=.*/Session\\\Interface=tun0/" /config/qBittorrent/qBittorrent.conf
    sed -i  "s/Session\\\InterfaceName=.*/Session\\\InterfaceName=tun0/" /config/qBittorrent/qBittorrent.conf
elif $(ip link list | grep -q tun0); then
    # Insist on wg0
    sed -i  "s/Session\\\Interface=.*/Session\\\Interface=wg0/" /config/qBittorrent/qBittorrent.conf
    sed -i  "s/Session\\\InterfaceName=.*/Session\\\InterfaceName=wg0/" /config/qBittorrent/qBittorrent.conf
fi

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
