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
# Channels:
#   main    →  full sha of the latest commit on the fork's main branch.
#              Tracks rolling. HelmReleases shouldn't pin to this.
#   stable  →  tag_name of the latest release-please-cut GitHub Release
#              (e.g. v0.1.0). Stable image tag suitable for HelmRelease
#              pinning.

set -euo pipefail

channel="${1:-main}"
repo="elfhosted/PostersPlus"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

case "$channel" in
  stable)
    version="$(
      curl -fsSL \
        -H "$auth_header" \
        "https://api.github.com/repos/${repo}/releases/latest" \
      | jq -r '.tag_name'
    )"
    ;;
  *)
    version="$(
      curl -fsSL \
        -H "$auth_header" \
        "https://api.github.com/repos/${repo}/commits/main" \
      | jq -r '.sha'
    )"
    ;;
esac

printf '%s' "${version}"
