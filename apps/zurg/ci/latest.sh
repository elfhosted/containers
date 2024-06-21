#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "rc" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/debridmediamanager/zurg/releases --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | first | .tag_name')
    version="2024.06.20-nightly" # until current bug is fixed
else
    version=$(curl -sX GET https://api.github.com/repos/debridmediamanager/zurg-testing/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
    version="${version#*release-}"
    printf "%s" "${version}"    
fi

printf "%s" "${version}"

