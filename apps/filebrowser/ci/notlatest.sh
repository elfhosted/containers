#!/usr/bin/env bash
channel=$1
if [[ "${channel}" == "quantum" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/gtsteffaniak/filebrowser/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
else
    printf "2.23.0"
fi
printf "%s" "${version}"   