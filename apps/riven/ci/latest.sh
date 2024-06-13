#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "test" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/rivenmedia/riven/commits/fix_id" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET "https://api.github.com/repos/rivenmedia/riven/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
fi

printf "%s" "${version}"
