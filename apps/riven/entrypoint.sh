#!/bin/ash

# Start riven in the background
tmux -f /iceberg/restricted.tmux.conf new-session -x 80 -y 24 -A -d -s riven /iceberg/riven.sh

# Prepare a tmux entry to the already-running process
ttyd -p 3001 -W -t titleFixed='Riven | ElfHosted' -t 'theme={"background": "#0B181C"}' -t drawBoldTextInBrightColors=false /iceberg/launch-tmux.sh
