#!/usr/bin/env bash
set -euo pipefail

# tofa's source repo is private, so there are no GitHub releases to follow.
# Track the highest plain X.Y.Z tag on the published image instead, which skips
# "latest", "beta" and the preview-*/test-* builds pushed alongside releases.
repo="tofatv/tofa"
token=$(curl -fsSL "https://ghcr.io/token?scope=repository:${repo}:pull" | jq --raw-output '.token')
version=$(curl -fsSL -H "Authorization: Bearer ${token}" "https://ghcr.io/v2/${repo}/tags/list?n=1000" \
  | jq --raw-output '.tags[]' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)
if [[ -z "${version}" ]]; then
  echo "ERROR: tofa latest version resolved empty from ghcr.io/${repo}" >&2
  exit 1
fi
printf "%s" "${version}"
