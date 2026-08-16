#!/usr/bin/env bash
set -euo pipefail

# Optional auth: only send the header when a token is actually present so we
# never emit a bare "Authorization: Bearer " (which trips GitHub's API).
token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
auth=()
if [[ -n "${token}" ]]; then
  auth=(--header "Authorization: Bearer ${token}")
fi

version=$(curl -fsSL "${auth[@]}" \
  "https://api.github.com/repos/Freika/dawarich/releases/latest" \
  | jq --raw-output '.tag_name')

# Strip an optional leading "v" to match the tag the Dockerfile expects.
version="${version#v}"

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "dawarich: failed to resolve latest upstream version" >&2
  exit 1
fi

printf "%s" "${version}"
