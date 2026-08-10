#!/usr/bin/env bash

# Remux is an EEP app built from a pinned upstream commit (REMUX_REF in the
# private Dockerfile), NOT from the latest release. The pin exists because the
# hosted image carries the inert-torrent-engine patch, which only applies
# against that exact tree. Bump this version string in lockstep with REMUX_REF
# whenever the patch is re-anchored onto a newer upstream commit — taking the
# version from upstream's latest release would trigger rebuilds the patch
# cannot survive.
#
# Lineage: v0.23.1 + 10 upstream commits (648d8c6). This version string only
# changes when the ref pin moves (patches re-anchored). Patch-series tweaks at
# the same ref rebuild the SAME tag with a fresh digest — myprecious pins
# tag@digest (jellyfin-style), so bumping the digest there is what rolls
# deployments. Read the digest from the Release Manual run log (GHCR is
# private to anonymous inspect).
printf "%s" "0.23.1-648d8c6"
