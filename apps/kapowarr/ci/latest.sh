#!/usr/bin/env bash
set -euo pipefail

channel=${1:-main}
api_args=(-fsSL)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    api_args+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
fi

if [[ "${channel}" == "dev" ]]; then
    version=$(curl "${api_args[@]}" "https://api.github.com/repos/Casvt/Kapowarr/commits/development" | jq --raw-output '.sha // empty')
else
    version=$(curl "${api_args[@]}" "https://api.github.com/repos/Casvt/Kapowarr/releases/latest" | jq --raw-output '.tag_name // empty')
fi

version="${version#V}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
    echo "failed to resolve Kapowarr ${channel} version" >&2
    exit 1
fi

printf "%s" "${version}"
