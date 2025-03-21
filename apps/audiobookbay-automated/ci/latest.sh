#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/JamesRy96/audiobookbay-automated/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"    



