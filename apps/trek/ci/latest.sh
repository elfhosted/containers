#!/usr/bin/env bash
set -euo pipefail

curl_args=(--header "Accept: application/vnd.github+json")
api_token="${TOKEN:-}"
api_token="${api_token:-${GITHUB_TOKEN:-}}"
api_token="${api_token:-${GH_TOKEN:-}}"
if [[ -n "${api_token}" ]]; then
    curl_args+=(--header "Authorization: Bearer ${api_token}")
fi

version=$(curl -fsSL "${curl_args[@]}" "https://api.github.com/repos/liketrek/TREK/releases/latest" | jq --raw-output .tag_name)
version="${version#v}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
    echo "failed to resolve latest TREK release" >&2
    exit 1
fi
printf "%s" "${version}"
