#!/usr/bin/env bash
set -euo pipefail
channel=${1:-main}

# gtsteffaniak/filebrowser publishes preview/beta tags as GitHub releases, and
# some preview releases are not flagged as prerelease by upstream. The stable
# channel must not follow those; only use tags that are explicitly stable-ish.
curl_args=(-fsSL "https://api.github.com/repos/gtsteffaniak/filebrowser/releases?per_page=100")
if [[ -n "${TOKEN:-}" ]]; then
    curl_args+=(--header "Authorization: Bearer ${TOKEN}")
fi
version=$(curl "${curl_args[@]}"   | jq --raw-output '[.[] | select(.draft == false) | select(.prerelease == false) | select(.tag_name | test("(?i)(preview|alpha|beta|rc)") | not)][0].tag_name')

if [[ -z "${version}" || "${version}" == "null" ]]; then
    echo "Unable to resolve a stable filebrowser release" >&2
    exit 1
fi

printf "%s" "${version}"
