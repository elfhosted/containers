#!/usr/bin/env bash
set -euo pipefail

repo="iuliandita/digarr"
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}" ]]; then
  headers+=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}")
fi

version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/${repo}/releases/latest" | jq --raw-output '.tag_name')
version="${version#v}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: digarr latest release resolved empty/null" >&2
  exit 1
fi
printf "%s" "${version}"
