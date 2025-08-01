#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "develop" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/jamcalli/pulsarr/commits/master --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/jamcalli/pulsarr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"