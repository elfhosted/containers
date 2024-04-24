#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/marcojoao/cyberflix-server/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"