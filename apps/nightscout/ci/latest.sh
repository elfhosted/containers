#!/usr/bin/env bash
set -euo pipefail

auth_token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${auth_token}" ]]; then
  headers+=(-H "Authorization: Bearer ${auth_token}")
fi

version=$(curl -fsSL "${headers[@]}"   https://api.github.com/repos/nightscout/cgm-remote-monitor/releases/latest   | jq --raw-output '.tag_name // empty')

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "nightscout latest release resolved empty/null" >&2
  exit 1
fi

printf "%s" "${version}"
