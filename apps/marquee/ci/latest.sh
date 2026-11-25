#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/jeremehancock/Marquee/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
if [[ -z "${version}" || "${version}" == "null" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/jeremehancock/Marquee/tags" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].name')
fi
version="${version#*v}"
printf "%s" "${version}"
