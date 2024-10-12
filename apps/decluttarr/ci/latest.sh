#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/ManiMatter/decluttarr/commits/dev" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
version="${version#*release-}"
printf "%s" "${version}"
