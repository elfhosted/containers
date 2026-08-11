#!/usr/bin/env bash
set -euo pipefail

repo="MunifTanjim/stremthru"

headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  headers+=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-}}")
fi

# This repo publishes SDK releases (sdk-py-*, sdk-js-*) alongside the server,
# so `releases/latest` is not necessarily a StremThru server release. Today it
# happens to be one; the next SDK release would resolve to a tag that clones
# cleanly and builds a tree that is not the server, silently rolling the
# deployed server back.
#
# Take the newest published release whose tag is a server version (N.N.N).
version=""
for page in 1 2 3; do
  version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/${repo}/releases?per_page=100&page=${page}" \
    | jq --raw-output '[.[] | select(.draft == false and .prerelease == false) | .tag_name | select(test("^[0-9]"))] | first // empty')
  if [[ -n "${version}" ]]; then
    break
  fi
done

if [[ -z "${version}" ]]; then
  echo "ERROR: no ${repo} server release (N.N.N) in the 300 most recent releases" >&2
  exit 1
fi

printf "%s" "${version}"
