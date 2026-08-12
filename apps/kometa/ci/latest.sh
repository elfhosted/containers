#!/usr/bin/env bash
set -euo pipefail

repo="Kometa-Team/Kometa"
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}" ]]; then
  token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
  headers+=(-H "Authorization: Bearer ${token}")
fi
url="https://api.github.com/repos/${repo}/releases/latest"
version=$(curl -fsSL "${headers[@]}" "$url" | jq --raw-output '.tag_name')
version="${version#release-}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: kometa resolved empty/null from ${url}" >&2
  exit 1
fi
printf "%s" "${version}"
