#!/usr/bin/env bash
version=$(curl -L -sX GET "https://api.github.com/repos/0x2E/fusion/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
