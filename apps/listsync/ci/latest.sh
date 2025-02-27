#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/Woahai321/ListSync/commits/dev" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version="$(curl -sX GET "https://api.github.com/repos/Woahai321/ListSync/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')"
fi
printf "%s" "${version}"