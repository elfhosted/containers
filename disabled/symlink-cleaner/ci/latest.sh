#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/bsm-elf/symlink-cleaner/commits/main" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/bsm-elf/symlink-cleaner/releases --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | first | .tag_name')
fi

printf "%s" "${version}"