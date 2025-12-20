#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/nzbdav-dev/nzbdav/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
elif [[ "${channel}" == "nzb-external-storage" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/elfhosted/nzbdav/commits/feature/nzb-external-storage" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/nzbdav-dev/nzbdav/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"