#!/usr/bin/env bash
# version=$(curl -sX GET https://api.github.com/repos/mhdzumair/MediaFusion/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
# version="${version#*v}"
# printf "%s" "${version}"
printf "%s" "v4.20.8" # hard-coded for now
