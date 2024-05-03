#!/bin/ash


# echo "Hit enter to start (or wait 5 min for auto-start, which will result in garbage printed to the screen until you hit enter)..."
# read -t 300
tmux -f /usr/src/app/restricted.tmux.conf new-session -A -s plex_debrid /plex-debrid.sh

