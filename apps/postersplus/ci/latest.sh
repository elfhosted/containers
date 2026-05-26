#!/usr/bin/env bash
# Fetch the latest version identifier for the postersplus image.
#
# Source: https://github.com/elfhosted/PostersPlus (private fork of
# UmbraProjects/PostersPlus with hosting-mode opt-in backends).
#
# Credentials come from ZURG_GH_CREDS — action-image-build.yaml already
# threads this through for cross-app use (same pattern as aioratings,
# comet, elfbot). The default TOKEN doesn't have access to private repos.
#
# Returns the tag_name of the latest release-please-cut GitHub Release
# (e.g. v0.1.0). The Dockerfile's `git checkout "${VERSION}"` accepts
# both tags and shas, so if a rolling-sha channel is ever re-introduced
# the only change needed is to switch this endpoint.

set -euo pipefail

repo="elfhosted/PostersPlus"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

version="$(
  curl -fsSL \
    -H "$auth_header" \
    "https://api.github.com/repos/${repo}/releases/latest" \
  | jq -r '.tag_name'
)"

printf '%s' "${version}"
