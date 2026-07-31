#!/usr/bin/env bash
# harbor-site: nginx serving Harbor's apex marketing site out of Backblaze B2.
#
# THERE IS NOTHING UPSTREAM TO RESOLVE. Every other harbor-* app here reads a
# release tag out of harborstremio/harbor-hosted; this one has no source
# repository at all. The entire image is the nginx configuration and the njs
# signing module in containers-private/apps/harbor-site/, and the site content it
# serves is not in the image -- it is 114 MB of objects in the elfhosted-harbor
# bucket under ${HARBOR_S3_PREFIX}site/, which is why a content change needs no
# build.
#
# SO THIS VERSION IS HAND-MAINTAINED, AND IT IS THE ONLY LEVER THAT MOVES THE
# IMAGE. Change anything in containers-private/apps/harbor-site/ and bump it in
# the same pull request. Skipping the bump does not fail: it produces new image
# contents under a tag that already exists, so the HelmRelease has nothing to
# change, Flux has nothing to reconcile, and imagePullPolicy IfNotPresent serves
# the old layer even across a pod restart. That is the trap recorded in
# harbor-hosted's HANDOVER.md §2, and here there is no tag to forget to cut --
# only this line.
#
# The same pattern is used by apps/dante and apps/tinyproxy, for the same reason.
#
# CHANGELOG
#   1.0.0  initial: apex site at /, /api/curated/ and /api/hero/ from B2
set -uo pipefail

printf '%s' "1.0.0"
