#!/bin/ash

# If the VPN_ENDPOINT_IP is not an IP address, then convert it to one

if echo "$VPN_ENDPOINT_IP" | egrep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
then
    echo "No changes, VPN_ENDPOINT_IP is an IP"
else
    export VPN_ENDPOINT_IP=$(dig +short $VPN_ENDPOINT_IP)
fi

exec \
    /gluetun-entrypoint
