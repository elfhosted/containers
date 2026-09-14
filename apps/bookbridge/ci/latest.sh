#!/usr/bin/env bash
set -euo pipefail

channel=${1:-main}
repo="cporcellijr/bookbridge"
api_args=(-fsSL)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    api_args+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
fi

if [[ "${channel}" == "dev" ]]; then
    version=$(curl "${api_args[@]}" "https://api.github.com/repos/${repo}/commits/dev" | jq --raw-output '.sha // empty')
else
    version=$(curl "${api_args[@]}" "https://api.github.com/repos/${repo}/releases/latest" | jq --raw-output '.tag_name // empty')
fi

if [[ -z "${version}" || "${version}" == "null" ]]; then
    echo "failed to resolve BookBridge ${channel} version" >&2
    exit 1
fi

# Upstream tags keep their leading "v" (v7.6.0), and the Dockerfile clones the
# tag verbatim, so do not strip it here.
printf "%s" "${version}"
