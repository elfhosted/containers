#!/usr/bin/env bash
channel=$1
version=$(curl -sX GET https://api.github.com/repos/xXCrash2BomberXx/tvgardenio/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
printf "%s" "${version}"   