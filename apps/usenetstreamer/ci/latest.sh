#!/usr/bin/env bash
set -euo pipefail
repo="Sanket9225/UsenetStreamer"
header=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  header=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
elif [ -n "${GH_TOKEN:-}" ]; then
  header=(-H "Authorization: Bearer ${GH_TOKEN}")
elif [ -n "${TOKEN:-}" ]; then
  header=(-H "Authorization: Bearer ${TOKEN}")
fi
version=$(curl -fsSL "${header[@]}" "https://api.github.com/repos/${repo}/commits/master" | jq --raw-output '.sha // empty')
if [ -z "${version}" ]; then
  echo "Unable to resolve ${repo} master SHA" >&2
  exit 1
fi
printf "%s" "${version}"
