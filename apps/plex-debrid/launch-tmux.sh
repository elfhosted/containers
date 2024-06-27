#!/bin/ash

tmux -f /usr/src/app/restricted.tmux.conf new-session -A -s plex_debrid /plex-debrid.sh

