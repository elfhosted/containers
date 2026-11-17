#!/usr/bin/env bash

# The main channel is pinned to a reviewed release. Move the pin only after
# reviewing a release's license terms.
PINNED_VERSION="v4.0.0"

printf "%s" "${PINNED_VERSION}"
