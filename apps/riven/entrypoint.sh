#!/bin/ash

# tmux -f /usr/src/app/restricted.tmux.conf new-session -A -d -s riven /riven.sh

yarn start --command /iceberg/launch-tmux.sh --base / --title "Riven | ElfHosted"