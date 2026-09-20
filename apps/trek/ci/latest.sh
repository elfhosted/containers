#!/usr/bin/env bash
set -euo pipefail

header=()
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}" ]]; then
  header=(--header "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}")
fi

version=$(curl -fsSL "${header[@]}" "https://api.github.com/repos/liketrek/TREK/releases/latest" | jq --raw-output .tag_name)
version="${version#v}"

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "failed to resolve latest TREK release" >&2
  exit 1
fi

printf "%s" "${version}"
