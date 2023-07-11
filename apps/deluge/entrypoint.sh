#!/usr/bin/env bash

set -e

#shellcheck disable=SC1091
source "/scripts/umask.sh"
source "/scripts/vpn.sh"

# If we have been given a port by pia/gluetun, insert it into the config before starting
if [[ ! -z "$PORT_FILE" ]]; then
    # Wait for port file to appear
    until [[ -f $PORT_FILE ]]; do
        echo waiting for port-forward details...
        sleep 5s
    done
        JQ_FILTER=" .listen_ports=[$(cat $PORT_FILE),$(cat $PORT_FILE)]"
        jq "${JQ_FILTER}" /config/core.conf > /config/core-new.conf
        cp /config/core-new.conf /config/core.conf
fi 

# Assume wireguard
exec /usr/bin/deluged -L info -d -c /config -o ${VPN_IF:=wg0}