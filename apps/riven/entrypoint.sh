#!/bin/ash

cd /usr/src/app
tmux -f /iceberg/restricted.tmux.conf new-session -A -d -s riven /iceberg/riven.sh

yarn start --command /iceberg/launch-tmux.sh --base / --title "Riven | ElfHosted"

# wetty --command top --base / --title "Riven | ElfHosted"