#!/usr/bin/env bash
# version=$(curl -sX GET https://api.github.com/repos/mhdzumair/MediaFusion/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
# version="${version#*v}"
# printf "%s" "${version}"
print "v5.0.0-beta.0" # hard-coded for now
