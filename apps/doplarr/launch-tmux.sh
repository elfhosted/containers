#!/bin/ash

tmux -f /restricted.tmux.conf new-session -A -s doplarr /doplarr.sh
