#!/usr/bin/env bash
set -euo pipefail

token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
headers=(-H "Accept: application/vnd.github+json" -H "User-Agent: elfhosted-plextraktsync-resolver")
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi
version=$(curl -fsSL "${headers[@]}" https://api.github.com/repos/Taxel/PlexTraktSync/tags   | jq -r '.[0].name // empty')
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "failed to resolve PlexTraktSync latest tag" >&2
  exit 1
fi
printf "%s" "${version}"
