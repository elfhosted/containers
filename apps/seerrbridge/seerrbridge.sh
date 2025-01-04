#!/bin/bash

# if [[ -z "$PLEX_TOKEN" ]]; 
# then
#     echo "seerrbridge is an alternate way to consume your debrid media in Plex"
#     echo "You don't HAVE to configure this, it's harmless to ignore it"
#     echo "To activate seerrbridge, you'll need to point your Plex Libraries to:"
#     echo "  /storage/symlinks/seerrbridge/Movies"
#     echo "  /storage/symlinks/seerrbridge/Series"
#     echo "And then use https://plex-token-generator.elfhosted.com to generate a token, and add it"
#     echo "by running 'elfbot env seerrbridge PLEX_TOKEN=<token>' in ElfTerm, and waiting for seerrbridge to restart"
#     sleep infinity 
# fi

uvicorn seerrbridge:app --host 0.0.0.0 --port 8777


echo "seerrbridge has unexpectedly exited :( Press any key to restart, or wait 5 min... (incase you need to capture debug output)"
read -s -n 1 -t 300