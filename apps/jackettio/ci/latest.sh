#!/usr/bin/env bash
# jackettio-internal's default branch is master, not main. This asked for
# /commits/main, which 422s ("No commit found for SHA: main"), so the version
# resolved to null and fetch.sh skipped the app every cycle — jackettio could
# not be rebuilt at all. The published image is still tagged literally "null"
# from 2026-05-22, minted before the build gained its null-tag guard.
#
# -f plus `// empty` so a failed lookup prints nothing rather than the string
# "null": fetch.sh treats empty as "lookup failed, skipping", which is what
# should have happened here all along.
version=$(curl -L -sfX GET "https://api.github.com/repos/elfhosted/jackettio-internal/commits/master" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha // empty')
printf "%s" "${version}"
