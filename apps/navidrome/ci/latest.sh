#!/usr/bin/env bash
set -euo pipefail

auth_token="${TOKEN:-}"
if [[ -z "${auth_token}" ]]; then
  auth_token="${GITHUB_TOKEN:-}"
fi
if [[ -z "${auth_token}" ]]; then
  auth_token="${GH_TOKEN:-}"
fi

headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${auth_token}" ]]; then
  headers+=(-H "Authorization: Bearer ${auth_token}")
fi

version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/navidrome/navidrome/releases/latest" | jq --raw-output '.tag_name')
version="${version#*v}"
version="${version#*release-}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "failed to resolve navidrome latest release" >&2
  exit 1
fi
printf "%s" "${version}"
