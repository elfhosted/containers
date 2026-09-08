#!/usr/bin/env bash
set -euo pipefail
channel="${1:-main}"
repo="DemFaR/stremio-trakt-addon"
api="https://api.github.com/repos/${repo}"
headers=()
if [[ -n "${ZURG_GH_CREDS:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${ZURG_GH_CREDS}")
elif [[ -n "${TOKEN:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${TOKEN}")
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
elif [[ -n "${GH_TOKEN:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${GH_TOKEN}")
fi
if [[ "${channel}" == "dev" ]]; then
  version=$(curl -fsSL "${api}/commits/main" "${headers[@]}" | jq --raw-output '.sha')
else
  version=$(curl -fsSL "${api}/releases/latest" "${headers[@]}" | jq --raw-output '.tag_name')
fi
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "mytrakt latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
