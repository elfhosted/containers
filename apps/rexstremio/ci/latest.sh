#!/usr/bin/env bash
# rex-stremio has no releases: track main's latest commit
version=$(curl -L -sX GET "https://api.github.com/repos/debridmediamanager/rex-stremio/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha[0:7]')
printf "%s" "${version}"
