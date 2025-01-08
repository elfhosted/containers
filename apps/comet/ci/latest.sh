#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "rewrite" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/g0ldyy/comet/commits/rewrite" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET "https://api.github.com/repos/elfhosted/comet/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
fi
printf "%s" "${version}"