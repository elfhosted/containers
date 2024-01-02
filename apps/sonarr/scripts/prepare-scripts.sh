#!/bin/ash

git clone https://github.com/RandomNinjaAtk/arr-scripts.git /tmp/arr-scripts
cd /tmp/arr-scripts

for service in $(ls sonarr/*.service); do
    mkdir -p /etc/s6-overlay/s6-rc.d/$service
    mv $service /etc/s6-overlay/s6-rc.d/$service/run
    echo longrun > /etc/s6-overlay/s6-rc.d/$service/type
done