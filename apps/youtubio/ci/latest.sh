#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/xXCrash2BomberXx/YouTubio/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
