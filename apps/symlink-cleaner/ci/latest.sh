#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/bsm-elf/symlink-cleaner/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"    



