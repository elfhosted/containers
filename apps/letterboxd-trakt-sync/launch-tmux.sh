#!/bin/bash

tmux -f /restricted.tmux.conf new-session -A -s letterboxd-trakt-sync /letterboxd-trakt-sync.sh

