#!/bin/bash

cp /XTerm /config

# Deal with the issue where PD sometimes exits and restarts with the wrong config path
ln -sf /config/elfhosted/settings.json /config/settings.json

cd /config/elfhosted
xterm -maximized -e "python /plex_debrid/main.py --c"