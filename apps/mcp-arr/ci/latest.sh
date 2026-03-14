#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/aplaceforallmystuff/mcp-arr/commits?per_page=1" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].sha')
else
    version=$(curl -sX GET https://api.github.com/repos/aplaceforallmystuff/mcp-arr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"