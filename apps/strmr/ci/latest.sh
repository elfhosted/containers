#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/godver3/strmr/releases --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].tag_name')
else
    version=$(curl -sX GET https://api.github.com/repos/godver3/strmr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"