#!/usr/bin/env bash
set -euo pipefail

repo="grimmory-tools/grimmory"
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  headers+=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-}}")
fi

version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/${repo}/releases/latest" | jq --raw-output '.tag_name')
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: grimmory latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
