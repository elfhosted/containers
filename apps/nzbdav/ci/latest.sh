#!/usr/bin/env bash

# nzbdav has a single channel, main, which builds the community fork
# (nzbdav/nzbdav) from a pinned FORK_REF in the Dockerfile. The version is
# maintained here in lockstep with that pin — NOT taken from the fork's latest
# release, which would mislabel images the moment the fork tags a release we
# have not rebased onto yet.
printf "%s" "v0.9.0"
