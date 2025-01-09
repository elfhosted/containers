#!/usr/bin/env bash
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/godver3/cli_debrid/releases --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].tag_name')
else
    version=$(curl -sX GET https://api.github.com/repos/godver3/cli_debrid/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"