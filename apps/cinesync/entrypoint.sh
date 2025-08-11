#!/usr/bin/env bash

WAIT_FOR_MOUNT_PATHS=$SOURCE_DIR
source "/scripts/mounts.sh"

# Run Cinesync
python WebDavHub/scripts/start-prod.py