#!/usr/bin/env bash
channel=$1
if [[ "${channel}" == "quantum" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/gtsteffaniak/filebrowser/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
else
    version=$(curl -sX GET https://api.github.com/repos/filebrowser/filebrowser/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"   