#!/bin/bash

echo "Press any key to drop to a shell, or wait 10 seconds for a normal start..."

# -t 5: Timeout of 5 seconds
read -s -n 1 -t 10

if [ $? -eq 0 ]; then
    echo "You pressed a key! Dropping to shell.."
    /usr/bin/fish
else
    echo "Timeout reached. Continuing boring normal start..."
    python3 kometa.py
fi



