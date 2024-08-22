#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/hexdecimal16/stremio-rating-addon/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"