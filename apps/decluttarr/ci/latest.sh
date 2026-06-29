#!/usr/bin/env bash
# Resolve the dev-branch HEAD sha for decluttarr (we track upstream `dev`).
#
# IMPORTANT: emit a single clean sha or NOTHING. A malformed/`null` version
# can never match the published image's label, which forces a rebuild every
# schedule tick — each one re-tags :rolling with a fresh digest and floods the
# myprecious release PR with bogus digest bumps. (This script previously
# printf'd the sha twice and emitted `nullnull` on a failed lookup.)
set -o pipefail

version=$(curl -sfX GET "https://api.github.com/repos/ManiMatter/decluttarr/commits/dev" \
    --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha // empty')

# Empty/null lookup → emit nothing and exit non-zero. fetch.mjs skips apps
# whose lookup fails, so we never build/tag a null version.
if [[ -z "${version}" ]]; then
    echo "decluttarr: could not resolve dev HEAD sha" >&2
    exit 1
fi

printf "%s" "${version}"
