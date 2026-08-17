#!/usr/bin/env bash
# `parent` is our own code and has no upstream to track, so the version is
# declared here and bumped by hand on release. Renovate has nothing to watch.
#
# Bump this when apps/parent/ changes in containers-private, otherwise the tag
# stays put across rebuilds and imagePullPolicy: IfNotPresent leaves nodes that
# already cached it running the OLD build forever. The chart pins the digest for
# exactly that reason, but a moving tag is still the clearer signal.
printf "%s" "1.9.0"