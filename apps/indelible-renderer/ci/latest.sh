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
  "https://api.github.com/repos/useindelible/indelible/releases/latest" \
  | jq --raw-output '.tag_name')

# Upstream tags releases "vX.Y.Z" but publishes its images as "X.Y.Z", which is
# what the Dockerfile pulls.
version="${version#v}"

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "indelible: failed to resolve latest upstream version" >&2
  exit 1
fi

printf "%s" "${version}"
