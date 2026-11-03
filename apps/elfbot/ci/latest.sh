#!/usr/bin/env bash
channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -L -sX GET "https://api.github.com/repos/elfhosted/elfbot/commits/develop" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
else
    version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/elfbot/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"   