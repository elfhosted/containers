#!/usr/bin/env bash
set -euo pipefail

# Track latest stable Infinidysk (formerly nzbdav) release, while keeping the
# ElfHosted container/app name `nzbdav`.
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  headers+=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-}}")
fi
version=$(curl -fsSL "${headers[@]}" \
  https://api.github.com/repos/infinidysk/infinidysk/releases/latest \
  | jq -r '.tag_name')
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: nzbdav/infinidysk latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
