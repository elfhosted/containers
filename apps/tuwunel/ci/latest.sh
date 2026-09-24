#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/matrix-construct/tuwunel/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
