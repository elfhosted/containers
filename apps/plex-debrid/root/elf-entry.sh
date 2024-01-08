#!/bin/bash

cp /XTerm /config
cd /config/elfhosted
uxterm -e "python /plex_debrid/main.py --c"