#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/Jackett/Jackett/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*v}"
printf "%s" "${version}"
