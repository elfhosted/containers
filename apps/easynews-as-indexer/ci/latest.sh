#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/sanket9225/Easynews_as_indexer/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
