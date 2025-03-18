#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "devel" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/jamcalli/pulsarr/commits/devel --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/jamcalli/pulsarr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"