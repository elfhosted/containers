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
# Channel:
#   main  →  full sha of the latest commit on the fork's main branch.
#            The fork doesn't tag releases yet; once it does, this can
#            switch to /releases/latest for a stable channel.

set -euo pipefail

channel="${1:-main}"
repo="elfhosted/PostersPlus"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

version="$(
  curl -fsSL \
    -H "$auth_header" \
    "https://api.github.com/repos/${repo}/commits/main" \
  | jq -r '.sha'
)"

printf '%s' "${version}"
