#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/jamcalli/elfbot/commits/develop" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
printf "%s" "${version}"