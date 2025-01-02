#!/bin/bash

if [[ -z "$PLEX_TOKEN" ]]; 
then
    echo "CineSync is an alternate way to consume your debrid media in Plex"
    echo "You don't HAVE to configure this, it's harmless to ignore it"
    echo "To activate CineSync, you'll need to point your Plex Libraries to:"
    echo "  /storage/symlinks/cinesync/movies"
    echo "  /storage/symlinks/cinesync/series"
    echo "And then use https://plex-token-generator.elfhosted.com to generate a token, and add it"
    echo "by running 'elfbot env cinesync PLEX_TOKEN=<token>' in ElfTerm, and waiting for CineSync to restart"
    sleep infinity 
fi

python3 MediaHub/main.py --auto-select

echo "Cinesync has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300