#!/usr/bin/env bash

channel=$1
version=$(curl -sX GET "https://api.github.com/repos/p-stream/simple-proxy/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"