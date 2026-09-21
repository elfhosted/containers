#!/usr/bin/env bash
set -euo pipefail

token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
headers=()
if [[ -n "${token}" ]]; then
  headers+=(--header "Authorization: Bearer ${token}")
fi

version=$(curl -fsSL "https://api.github.com/repos/liketrek/TREK/releases/latest" "${headers[@]}" | jq --raw-output '.tag_name // empty')
version="${version#v}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "failed to resolve latest TREK release" >&2
  exit 1
fi
printf "%s" "${version}"
