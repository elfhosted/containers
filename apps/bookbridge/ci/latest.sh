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

# Strip the leading "v" (v7.6.0 -> 7.6.0). The Dockerfile puts it back for the
# clone. It comes off here because this string is also baked in as APP_VERSION,
# and upstream's update check compares it against the GitHub tag_name with the
# "v" already lstripped -- so a "v"-prefixed APP_VERSION never matches and the
# dashboard reports an update is available on the very release it is running.
version="${version#v}"

printf "%s" "${version}"
