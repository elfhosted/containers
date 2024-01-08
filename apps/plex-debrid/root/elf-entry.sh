#!/bin/bash

cp /XTerm /config
cd /config/elfhosted
xterm -maximized -e "python /plex_debrid/main.py --c"