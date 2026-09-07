#!/usr/bin/env bash
set -euo pipefail

headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi
version=$(curl -fsSL "${headers[@]}" \
  https://api.github.com/repos/Gaisberg/streamnzb/releases/latest \
  | jq -r '.tag_name // empty')
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: streamnzb latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
