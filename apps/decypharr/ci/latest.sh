#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "beta" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/sirrobot01/decypharr/commits/beta" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/sirrobot01/decypharr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"