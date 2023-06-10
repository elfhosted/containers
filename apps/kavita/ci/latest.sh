#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/Kareadita/Kavita/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
