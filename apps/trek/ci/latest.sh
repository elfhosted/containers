#!/usr/bin/env bash
set -euo pipefail

headers=()
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}" ]]; then
  headers=(--header "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}")
fi

version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/liketrek/TREK/releases/latest" | jq --raw-output '.tag_name // empty')
version="${version#v}"
if [[ -z "$version" || "$version" == "null" ]]; then
  echo "Unable to resolve latest TREK release" >&2
  exit 1
fi
printf "%s" "$version"
