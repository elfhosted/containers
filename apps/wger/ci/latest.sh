#!/usr/bin/env bash

version=$(curl -sX GET https://api.github.com/repos/wger-project/wger/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')

# printf "%s" "${version}"
printf %s "2.4"