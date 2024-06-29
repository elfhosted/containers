#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/iPromKnight/zilean/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"