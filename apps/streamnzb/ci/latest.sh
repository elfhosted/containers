#!/usr/bin/env bash
set -euo pipefail

# Track the latest upstream StreamNZB release for the image label. The
# Dockerfile (containers-private) pins its own UPSTREAM_REF for the patch
# series; when upstream releases run ahead of the pin, the label runs ahead
# too until the series is rebased — same trade nzbdav accepts.
headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi
version=$(curl -fsSL "${headers[@]}" \
  https://api.github.com/repos/Gaisberg/streamnzb/releases/latest \
  | jq -r '.tag_name')
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: streamnzb latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
