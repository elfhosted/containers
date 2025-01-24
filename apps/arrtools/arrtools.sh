#!/bin/bash

python3 MediaHub/main.py --auto-select

echo "Cinesync has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300