#!/usr/bin/env bash
set -euo pipefail
repo="vavallee/bindery"
headers=()
if [[ -n "${TOKEN:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${TOKEN}")
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
elif [[ -n "${GH_TOKEN:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${GH_TOKEN}")
elif [[ -n "${ZURG_GH_CREDS:-}" ]]; then
  headers+=(--header "Authorization: Bearer ${ZURG_GH_CREDS}")
fi
version=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" "${headers[@]}" | jq --raw-output '.tag_name')
version="${version#v}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "bindery latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
