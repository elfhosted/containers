#!/usr/bin/env bash

channel=$1
version=$(curl -sX GET "https://api.github.com/repos/stremio-internet-archive-addon/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"