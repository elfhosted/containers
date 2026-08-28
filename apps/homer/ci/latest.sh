#!/usr/bin/env bash
set -euo pipefail

repo="bastienwirtz/homer"
url="https://api.github.com/repos/${repo}/releases/latest"

headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi

version=$(curl -fsSL "${headers[@]}" "${url}" | jq --raw-output '.tag_name')

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: homer latest release resolved empty/null from ${url}" >&2
  exit 1
fi

printf "%s" "${version}"
