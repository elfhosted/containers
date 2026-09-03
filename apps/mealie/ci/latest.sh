#!/usr/bin/env bash
set -euo pipefail

headers=()
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}" ]]; then
  headers=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN}}}")
fi

version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/mealie-recipes/mealie/releases/latest" | jq --raw-output .tag_name)
if [[ -z "$version" || "$version" == "null" ]]; then
  echo "failed to resolve latest Mealie release" >&2
  exit 1
fi
printf "%s" "$version"
