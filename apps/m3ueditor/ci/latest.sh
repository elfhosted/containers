#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/m3ue/m3u-editor/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
