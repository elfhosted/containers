#!/usr/bin/env bash
# version=$(curl -sX GET https://api.github.com/repos/autobrr/autobrr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
# version="${version#*v}"
# version="${version#*release-}"
# printf "%s" "${version}"
echo 10.0.1 # until we can find a better way to determine the latest release