#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/stremify/stremify/commits/v2.7" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"