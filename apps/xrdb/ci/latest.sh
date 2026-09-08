#!/usr/bin/env bash
# XRDB -- eXtended Ratings DataBase.
# Source: https://github.com/IbbyLabs/XRDB (public)
#
# The Dockerfile and the patch stack live in containers-private, because the
# upstream repo declares no licence. Only the build metadata is here.
#
# Releases are cut by release-please from conventional commits on main, so
# releases/latest is always the newest server build. Tags are vN.N.N.

set -euo pipefail

repo="IbbyLabs/XRDB"

headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  headers+=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-}}")
fi

# Take the newest published, non-draft release whose tag is a v3-or-later
# version. v2 is a different application: it listened on 3000, kept its data
# somewhere else, and its profiles do not carry into v3. Pinning the major here
# means a v2 maintenance release cannot roll the public instance backwards onto
# a schema our patches do not fit.
version=""
for page in 1 2 3; do
  version=$(curl -fsSL "${headers[@]}" \
    "https://api.github.com/repos/${repo}/releases?per_page=100&page=${page}" \
    | jq --raw-output '[.[] | select(.draft == false and .prerelease == false)
                          | .tag_name | select(test("^v[3-9][0-9]*\\."))] | first // empty')
  if [[ -n "${version}" ]]; then
    break
  fi
done

if [[ -z "${version}" ]]; then
  echo "ERROR: no ${repo} release (v3+) in the 300 most recent releases" >&2
  exit 1
fi

printf "%s" "${version}"
