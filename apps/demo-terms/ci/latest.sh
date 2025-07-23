#!/usr/bin/env bash
channel=$1
version=$(curl -sX GET "https://api.github.com/repos/funkypenguin/demo-terms/commits/main" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
printf "%s" "${version}"   