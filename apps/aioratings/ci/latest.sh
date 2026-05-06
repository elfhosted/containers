#!/usr/bin/env bash
# AIORatings is the ElfHosted-internal Stremio ratings addon.
# Source: https://github.com/elfhosted/aioratings (private)
# Releases are cut by release-please from conventional commits on the
# codex_ratings_port branch. Credentials come from ZURG_GH_CREDS,
# already passed through action-image-build.yaml for cross-app use
# (same pattern as elfbot/comet).

set -euo pipefail

channel="${1:-main}"
repo="elfhosted/aioratings"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

case "$channel" in
  dev)
    version="$(
      curl -fsSL \
        -H "$auth_header" \
        "https://api.github.com/repos/${repo}/commits/codex_ratings_port" \
      | jq -r '.sha'
    )"
    ;;
  *)
    version="$(
      curl -fsSL \
        -H "$auth_header" \
        "https://api.github.com/repos/${repo}/releases/latest" \
      | jq -r '.tag_name'
    )"
    ;;
esac

printf '%s' "${version}"
