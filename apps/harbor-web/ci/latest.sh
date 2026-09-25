#!/usr/bin/env bash
set -uo pipefail

repo="harborstremio/harbor"
branch="stable-branch"

curl_args=(-fsSL)
if [[ -n "${ZURG_GH_CREDS:-}" ]]; then
    curl_args+=(-H "Authorization: Bearer ${ZURG_GH_CREDS}")
fi

version="$(
  curl "${curl_args[@]}" "https://api.github.com/repos/${repo}/commits/${branch}" \
  | jq -r '.sha[0:7] // empty'
)"

printf '%s' "${version}"
