#!/bin/ash

. /usr/src/app/plex_debrid/.venv/bin/activate
cd /config/
export TERM=tmux
python /usr/src/app/plex_debrid/main.py --c

