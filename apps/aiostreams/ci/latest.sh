#!/usr/bin/env bash
set -euo pipefail

channel="${1:-main}"
repo="Viren070/AIOStreams"

headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi

if [[ "${channel}" == "dev" ]]; then
  url="https://api.github.com/repos/${repo}/commits/main"
  version=$(curl -fsSL "${headers[@]}" "${url}" | jq --raw-output '.sha')
else
  # Upstream also publishes unrelated release lineages such as
  # seanime-extensions-vX.Y.Z. Track only stable AIOStreams application tags.
  url="https://api.github.com/repos/${repo}/releases?per_page=100"
  version=$(curl -fsSL "${headers[@]}" "${url}"     | jq --raw-output 'map(select(.draft==false and .prerelease==false and (.tag_name|test("^v[0-9]")))) | .[0].tag_name')
fi

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: AIOStreams ${channel} resolved empty/null from ${url}" >&2
  exit 1
fi

printf "%s" "${version}"
