#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/cedya77/aiometadata/tags" --header "Authorization: Bearer ${TOKEN}" | jq -r '.[0].name')
else
    version=$(curl -sX GET https://api.github.com/repos/cedya77/aiometadata/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"   