#!/usr/bin/env bash
set -euo pipefail

# Upstream moved the C# (1.x) line to the v1 maintenance branch; main is headed
# for a rewrite our Dockerfile and patches don't build. Track the newest 1.x
# release rather than releases/latest, which will flip to 2.x.
headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi
version=$(curl -fsSL "${headers[@]}" \
  "https://api.github.com/repos/infinidysk/infinidysk/releases?per_page=100" \
  | jq -r '.[] | select(.draft == false and .prerelease == false) | .tag_name' \
  | grep -E '^v1\.[0-9]+\.[0-9]+$' \
  | sort -V | tail -n 1)
if [[ -z "${version}" ]]; then
  echo "ERROR: nzbdav/infinidysk latest 1.x release resolved empty" >&2
  exit 1
fi
printf "%s" "${version}"
