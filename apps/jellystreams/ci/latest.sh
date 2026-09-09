#!/usr/bin/env bash
# `jellystreams` is our own code — a Jellyfin front end for a tenant's
# AIOStreams configuration — so there is no upstream release to track and
# renovate has nothing to watch. The version is declared here and bumped by
# hand.
#
# Bump this when apps/jellystreams/ changes in containers-private. Without a
# bump the tag stays put across rebuilds, and imagePullPolicy: IfNotPresent
# leaves nodes that already cached it running the OLD build forever. The chart
# pins the digest for exactly that reason, but a moving tag is still the
# clearer signal.
printf "%s" "0.11.14"
