#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "dev" ]]; then
    version=$(curl -L -sX GET "https://api.github.com/repos/debridmediamanager/zurg/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -L -sX GET https://api.github.com/repos/debridmediamanager/zurg/releases --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | first | .tag_name')
fi

printf "%s" "${version}"