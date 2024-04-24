#!/usr/bin/env bash

if [[ "${channel}" == "develop" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/marcojoao/cyberflix-server/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET "https://api.github.com/repos/marcojoao/cyberflix-server/commits/develop" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
fi
printf "%s" "${version}"