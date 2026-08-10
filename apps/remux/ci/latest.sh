#!/usr/bin/env bash

# Remux is an EEP app built from a pinned upstream commit (REMUX_REF in the
# private Dockerfile), NOT from the latest release. The pin exists because the
# hosted image carries the inert-torrent-engine patch, which only applies
# against that exact tree. Bump this version string in lockstep with REMUX_REF
# whenever the patch is re-anchored onto a newer upstream commit — taking the
# version from upstream's latest release would trigger rebuilds the patch
# cannot survive.
#
# Tracks upstream's latest release. The private Dockerfile builds v${VERSION}
# and hard-fails if the ElfHosted patch series doesn't apply against it —
# that failure is the signal for the automated hermes re-anchor job, which
# rebases the patches (each carries RE-ANCHORING NOTES) onto the new tag.
# Patch tweaks at the same version rebuild the SAME tag with a fresh digest;
# myprecious pins tag@digest, so digest bumps roll deployments.
version=$(curl -sX GET "https://api.github.com/repos/lostb1t/remux/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
