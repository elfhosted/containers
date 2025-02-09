#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].tag_name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
