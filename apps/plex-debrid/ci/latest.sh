#!/usr/bin/env bash
# Resolve the main-branch HEAD sha for the ElfHosted plex_debrid fork.
#
# IMPORTANT: emit a single clean `dev-<sha>` or NOTHING. A `dev-null` version
# (what a failed lookup used to produce) can never match the published image's
# label, forcing a rebuild every schedule tick — each re-tags :rolling with a
# fresh digest and floods the myprecious release PR with bogus digest bumps.
#
# Use ZURG_GH_CREDS (falls back to TOKEN) so the lookup is resilient if the
# fork's visibility changes — same pattern as plexio.
set -o pipefail

creds="${ZURG_GH_CREDS:-${TOKEN}}"
version=$(curl -sfX GET "https://${creds}@api.github.com/repos/elfhosted/plex_debrid/commits/main" \
    | jq --raw-output '.sha // empty')

if [[ -z "${version}" ]]; then
    echo "plex-debrid: could not resolve main HEAD sha" >&2
    exit 1
fi

printf "%s" "dev-${version}"
