#!/usr/bin/env bash
set -euo pipefail

channel="${1:-main}"
repo="godver3/mediastorm"
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  headers+=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-}}")
fi

if [[ "${channel}" == "dev" ]]; then
  url="https://api.github.com/repos/${repo}/commits?per_page=1"
  version=$(curl -fsSL "${headers[@]}" "$url" | jq --raw-output '.[0].sha')
else
  url="https://api.github.com/repos/${repo}/releases/latest"
  version=$(curl -fsSL "${headers[@]}" "$url" | jq --raw-output '.tag_name')
fi

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: mediastorm ${channel} resolved empty/null from ${url}" >&2
  exit 1
fi

printf "%s" "${version}"
