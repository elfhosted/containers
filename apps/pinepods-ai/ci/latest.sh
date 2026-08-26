#!/usr/bin/env bash
# `pinepods-ai` is our own code — an adapter between Pinepods' AI sidecar
# protocol and the shared whisperx service — so there is no upstream release to
# track and renovate has nothing to watch. The version is declared here and
# bumped by hand.
#
# Bump this when apps/pinepods-ai/ changes in containers-private. Without a bump
# the tag stays put across rebuilds, and imagePullPolicy: IfNotPresent leaves
# nodes that already cached it running the OLD build forever. The chart pins the
# digest for exactly that reason, but a moving tag is still the clearer signal.
printf "%s" "1.0.0"
