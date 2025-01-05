#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/Woahai321/SeerrBridge/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
# printf "%s" "${version}"    

printf "v0.4.5-beta"
