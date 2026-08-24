#!/usr/bin/env bash
# PINNED, not floating. The mover image and the volsync controller are
# version-coupled: the controller invokes mover scripts that live in this image,
# and their contract changes between minor releases. This must therefore track
# the volsync chart deployed in infra (volsync-system/helmrelease-volsync.yaml),
# NOT upstream's newest tag.
#
# To upgrade: bump the volsync HelmRelease and this pin in the same change.
printf "%s" "0.13.1"
