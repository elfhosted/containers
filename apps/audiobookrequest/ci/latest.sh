#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/markbeep/AudioBookRequest/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*}"
printf "%s" "${version}"
