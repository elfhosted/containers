#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/godver3/strmr/commits?per_page=1" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].sha')
else
    version=$(curl -sX GET https://api.github.com/repos/godver3/strmr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"