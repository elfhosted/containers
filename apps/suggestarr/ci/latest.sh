#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/giuseppe99barchetta/SuggestArr/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"