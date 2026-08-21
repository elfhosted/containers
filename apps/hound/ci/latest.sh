#!/usr/bin/env bash
set -euo pipefail

token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "$token" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi

version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/Hound-Media-Server/hound/releases/latest" | jq --raw-output '.tag_name // empty')
version="${version#v}"
if [[ -z "$version" || "$version" == "null" ]]; then
  echo "failed to resolve latest hound version" >&2
  exit 1
fi
printf "%s" "$version"
