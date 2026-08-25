#!/usr/bin/env bash
# The tag is not decorative: the Dockerfile installs exactly this rclone
# version (RCLONE_VERSION defaults to VERSION), so the tag states what is
# in the image.
#
# This used to return a hardcoded v1.74.4 — the repology lookup was commented
# out when it started 403ing, leaving only the "just fake it" fallback. That
# pinned the app twice: the version never changed, so fetch.sh never saw a new
# one and csi-rclone was never rebuilt on schedule again (its source repointed
# to the private org repo on 2026-08-19 and no image was ever built from it),
# and the bundled rclone never moved either.
#
# rclone's own releases API replaces repology — same answer, no scraping, and
# it is the authority for what the download URL will accept.
version=$(curl -L -sfX GET "https://api.github.com/repos/rclone/rclone/releases/latest" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')

# Print nothing on failure — fetch.sh reads empty as "lookup failed, skipping",
# which is the correct outcome for a transient API error. Substituting a
# constant is what silently froze this app for months.
printf "%s" "${version}"
