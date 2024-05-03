#!/bin/ash

tmux -f /usr/src/app/restricted.tmux.conf new-session -A -d -s plex_debrid /plex-debrid.sh

yarn start --command /launch-tmux.sh --base / --title "plex_debrid | ElfHosted"