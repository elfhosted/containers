#!/usr/bin/env bash
set -euo pipefail

# Track latest stable Infinidysk (formerly nzbdav) release, while keeping the
# ElfHosted container/app name `nzbdav`.
headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi
version=$(curl -fsSL "${headers[@]}"   https://api.github.com/repos/infinidysk/infinidysk/releases/latest   | jq -r '.tag_name')
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: nzbdav/infinidysk latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
