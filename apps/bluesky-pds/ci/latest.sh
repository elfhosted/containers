#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/bluesky-social/pds/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*v}"
printf "%s" "${version}"
