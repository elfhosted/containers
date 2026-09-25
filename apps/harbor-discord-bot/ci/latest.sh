#!/usr/bin/env bash
set -uo pipefail

repo="Talal1011/harbor-discord-bot"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

version="$(
  curl -fsSL -H "${auth_header}" \
    "https://api.github.com/repos/${repo}/releases/latest" \
  | jq -r '.tag_name // empty'
)"

if [[ -z "${version}" ]]; then
  version="$(
    curl -fsSL -H "${auth_header}" \
      "https://api.github.com/repos/${repo}/commits/main" \
    | jq -r '.sha[0:7] // empty'
  )"
fi

printf '%s' "${version}"
