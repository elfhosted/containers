#!/bin/bash

# run the script
cd /app
java -jar doplarr.jar
echo "doplarr has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300