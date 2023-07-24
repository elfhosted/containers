#!/usr/bin/env bash

# Execute any scripts found in /elfscript
for SCRIPT in $(ls /elfscript); do
    bash -c $SCRIPT
done
