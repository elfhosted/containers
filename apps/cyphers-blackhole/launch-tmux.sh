#!/bin/bash

tmux -f /restricted.tmux.conf new-session -A -s blackhole /blackhole.sh

