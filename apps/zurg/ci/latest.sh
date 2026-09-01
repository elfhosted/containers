#!/usr/bin/env bash
version=$(curl -L -sX GET https://api.github.com/repos/debridmediamanager/zurg-public/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*release-}"
printf "%s" "${version}"    
