#!/usr/bin/env bash
set -euo pipefail
channel=${1:-main}

token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
headers=(-H "Accept: application/vnd.github+json" -H "User-Agent: elfhosted-stremio-submaker-resolver")
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi
if [[ "${channel}" == "dev" ]]; then
  version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/xtremexq/StremioSubMaker/commits/main" | jq -r '.sha // empty')
else
  version=$(curl -fsSL "${headers[@]}" https://api.github.com/repos/xtremexq/StremioSubMaker/releases/latest | jq -r '.tag_name // empty')
fi
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "failed to resolve StremioSubMaker ${channel} version" >&2
  exit 1
fi
printf "%s" "${version}"
