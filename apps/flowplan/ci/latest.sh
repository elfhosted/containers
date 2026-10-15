#!/usr/bin/env bash
version=$(curl -L -sX GET "https://api.github.com/repos/yannicschuller/flowplan/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
