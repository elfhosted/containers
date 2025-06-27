#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/tapframe/NuvioStreamsAddon/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
elif [[ "${channel}" == "private" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/tapframe/NuvioStreamsAddon/commits/private" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/tapframe/NuvioStreamsAddon/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"