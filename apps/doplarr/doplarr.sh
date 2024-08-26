#!/bin/ash

echo "Starting Doplarr... it's a java app 🤮, this may take a little while, it's normal to see no output for up to a minute..."

# run the script
cd /app
java -jar doplarr.jar
echo "doplarr has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300