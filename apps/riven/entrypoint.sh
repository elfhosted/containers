#!/bin/ash

tmux -f /usr/src/app/restricted.tmux.conf new-session -A -d -s riven /iceberg/riven.sh

cd /usr/src/app/
wetty --command /iceberg/launch-tmux.sh --base / --title "Riven | ElfHosted"

# wetty --command top --base / --title "Riven | ElfHosted"