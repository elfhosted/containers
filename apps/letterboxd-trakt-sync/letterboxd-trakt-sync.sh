#!/bin/bash

python -u -m letterboxd_trakt.main

echo "Letterboxd Trakt Sync has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300