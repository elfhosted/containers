#!/bin/bash

if grep -q plex:32400 /home/elfie/.config/PlexTraktSync/servers.yml; then
    /home/elfie/.local/bin/plextraktsync watch
else
    echo "PlexTraktSync not setup for http://plex:32400, please use ElfTerm to configure it first"
fi
read -n 1 -s -r -p "Press any key to continue"