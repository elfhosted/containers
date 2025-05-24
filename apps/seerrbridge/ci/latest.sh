#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/Woahai321/SeerrBridge/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version="$(curl -sX GET "https://api.github.com/repos/Woahai321/SeerrBridge/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')"
fi
printf "%s" "${version}"