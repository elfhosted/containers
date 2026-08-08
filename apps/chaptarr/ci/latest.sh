#!/usr/bin/env bash
# Chaptarr publishes git tags (no GitHub releases), matching Docker Hub image tags without the "v" prefix
version=$(curl -sX GET "https://api.github.com/repos/Chaptarr/chaptarr/tags" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[].name' | grep -E '^v?[0-9]' | sort -V | tail -1)
version="${version#*v}"
printf "%s" "${version}"
