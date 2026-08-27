#!/usr/bin/env bash
# Tracks rclone's own releases. The build passes this through as VERSION, which
# the (private) Dockerfile uses for BOTH the image tag and ARG RCLONE_VERSION —
# so the tag always names the rclone binary actually inside the image, and the
# two cannot drift apart.
#
# `.tag_name // empty` on purpose: on a rate-limit, timeout or API error this
# must print NOTHING. fetch.sh treats an empty upstream version as "lookup
# failed", not "new version", and skips the rebuild. A fallback constant here is
# what broke this file before — the repology lookup it used to carry was fully
# commented out and fell through to a hardcoded v1.74.4. Since that equalled the
# published tag, the scheduler compared v1.74.4 to v1.74.4 forever and never
# rebuilt: csi-rclone looked tracked for months while being build-inert.
#
# Do NOT strip the leading v (bazarr and friends do; this must not). The
# Dockerfile builds the download URL as
# downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip,
# which requires the v-prefixed form.
#
# Safe to track automatically: a new build only produces a new tag. Both
# csi-nodeplugin-rclone.yaml and csi-controller-rclone.yaml pin the image by
# DIGEST in the infra repo, so nothing reaches a node until that digest is
# bumped in a reviewed PR. The plugin DaemonSet is additionally OnDelete, so
# rollout is driven by csi-rclone-roller / reboots after that merge.
version=$(curl -sX GET "https://api.github.com/repos/rclone/rclone/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
