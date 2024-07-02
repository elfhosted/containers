#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/elfhosted/plex-token-generator/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"