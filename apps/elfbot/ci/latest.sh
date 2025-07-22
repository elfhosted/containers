#!/usr/bin/env bash
channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/funkypenguin/elfbot/commits/develop" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/funkypenguin/elfbot/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"   