#!/usr/bin/env bash
set -euo pipefail

# Tracks upstream's latest stable release. The private Dockerfile builds v${VERSION}
# and hard-fails if the ElfHosted patch series does not apply against it; that
# failure is the signal to re-anchor the patch stack onto the new tag.
repo="lostb1t/remux"
url="https://api.github.com/repos/${repo}/releases/latest"

headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi

version=$(curl -fsSL "${headers[@]}" "${url}" | jq --raw-output '.tag_name')

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: remux latest release resolved empty/null from ${url}" >&2
  exit 1
fi

version="${version#v}"
printf "%s" "${version}"
