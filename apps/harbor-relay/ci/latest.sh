#!/usr/bin/env bash
# harbor-relay: the Harbor "Watch Together" WebSocket relay.
#
# ###########################################################################
# # THIS IMAGE IS BUILT FROM A KNOWN-STALE SOURCE. IT SHIPS RELAY_VERSION 9. #
# # PRODUCTION (the Harbor VPS) RUNS RELAY_VERSION 10.                       #
# ###########################################################################
#
# Read this before "fixing" the version string, because the staleness is
# deliberate and the tag is the loudest place to say so.
#
# Source: https://github.com/harborstremio/pub.harbor.site (PUBLIC, MIT).
# That repository is the ONLY source that can be reached without touching the
# production VPS, and it is a version behind what production runs. Verified by
# checksum on 2026-07-30 and recorded in harborstremio/harbor-hosted
# services/sources.yaml section 2: comparing src/*.js against /opt/harbor-relay
# on the VPS, four files are identical (guard.js, ipcap.js, rooms.js,
# validate.js) and FIVE DIFFER (limits.js, relay-handlers.js, room.js,
# sanitize.js, server.js). src/limits.js here says
#
#     export const RELAY_VERSION = 9;
#
# while the VPS says 10. The public repository carries no tags and no branches
# other than main, no fork, no npm package and no published container image, so
# there is nothing newer to pin to. Re-checked here on 2026-07-30:
#
#     tags:     []            (GET /repos/.../tags)
#     branches: [main]        (GET /repos/.../branches)
#     forks:    0             network_count 0
#     npm:      404           harbor-together-relay is not published
#     ghcr:     []            harborstremio publishes no container packages
#
# The authoritative copy is /opt/harbor-relay on the VPS, and copying from the
# VPS is out of scope here (harbor-hosted AGENTS.md rule 6 / read-only access).
# harbor-hosted's services/sources.yaml therefore DELIBERATELY does not declare
# harbor-relay, precisely so nobody clones the public repo and calls it current.
# This file exists because the CI deployment needs a real image; it is a
# deliberate, labelled v9 build, not a resolution of that question.
#
# WHEN THE RELAY SOURCE IS EVENTUALLY VENDORED into harbor-hosted from the VPS,
# retarget this script at that private repo (copy apps/harbor-tvdb/ci/latest.sh,
# which already does exactly that with ZURG_GH_CREDS) and delete the v9-stale
# labelling from here, the Dockerfile, the goss file and the HelmRelease.
#
# WHAT THIS EMITS: "v9-stale-<shortsha>", which becomes the image tag AND the
# --build-arg VERSION the Dockerfile resolves. Both halves are load-bearing:
#
#   * "v9-stale" makes the known-stale version visible in the image tag itself,
#     so it shows up in ghcr, in the HelmRelease, in `kubectl describe pod` and
#     in every screenshot of any of them. A bare sha would hide it.
#   * "<shortsha>" is the git ref. The Dockerfile takes the substring after the
#     last dash and checks it out, so the tag is self-describing AND the build
#     is reproducible. It pins a commit rather than tracking main, because main
#     is unprotected and a force-push would otherwise silently change what a
#     "v9-stale" tag contains.
#
# The Dockerfile ASSERTS RELAY_VERSION == 9 in the checked-out source and fails
# the build if it is not. So if upstream ever publishes v10, the sha moves, the
# assert fires, and the build fails LOUDLY instead of shipping a version the tag
# lies about. A build failing on that assert is the intended signal, not a bug:
# it means a human should go and re-read this comment.
#
# No credential is needed (public repo), but TOKEN (the workflow's own
# GITHUB_TOKEN) is used when present purely to avoid the 60/hour unauthenticated
# api.github.com rate limit. There is no fallback if the API call fails: an empty
# string makes action-image-build.yaml fail the build, which is the correct loud
# outcome. A hardcoded fallback sha would quietly paper over a broken lookup.
set -uo pipefail

repo="harborstremio/pub.harbor.site"

sha="$(
  curl -fsSL \
    ${TOKEN:+-H "Authorization: Bearer ${TOKEN}"} \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${repo}/commits/main" \
  | jq -r '.sha // empty'
)"

# Verified public HEAD as of 2026-07-30, for the record. NOT used as a fallback,
# only as documentation of what "v9-stale" was measured against:
#   5e7a2f355e62544e1b6943e125d0ca0352c6cd93

if [[ -z "${sha}" ]]; then
  # Emit nothing. action-image-build.yaml turns an empty version into a hard
  # build failure rather than tagging a null image.
  exit 0
fi

printf 'v9-stale-%s' "${sha:0:7}"
