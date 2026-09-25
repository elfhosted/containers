#!/usr/bin/env bash
set -uo pipefail

repo="harborstremio/harbor-hosted"
component="harbor-mal"
branch="feat/vendored-services-and-deployment"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

version="$(
  curl -fsSL -H "${auth_header}" \
    "https://api.github.com/repos/${repo}/tags?per_page=100" \
  | jq -r --arg c "${component}-v" '.[].name | select(startswith($c))' \
  | sed "s/^${component}-v//" \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
  | sort -V \
  | tail -n1 \
  | sed "s/^/${component}-v/"
)"

if [[ -z "${version}" ]]; then
  version="$(
    curl -fsSL -H "${auth_header}" \
      "https://api.github.com/repos/${repo}/commits/${branch}" \
    | jq -r '.sha[0:7] // empty'
  )"
fi

if [[ -z "${version}" ]]; then
  version="$(
    curl -fsSL -H "${auth_header}" \
      "https://api.github.com/repos/${repo}/commits/main" \
    | jq -r '.sha[0:7] // empty'
  )"
fi

printf '%s' "${version}"
