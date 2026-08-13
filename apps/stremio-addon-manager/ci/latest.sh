#!/usr/bin/env bash
version=$(curl -L -sX GET "https://api.github.com/repos/0xConstant1/stremio-addon-manager/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"   