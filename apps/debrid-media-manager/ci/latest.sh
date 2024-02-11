#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/geek-cookbook/debrid-media-manager/main/dev" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
