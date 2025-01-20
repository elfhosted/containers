#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/skjaere/debridav/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version=v0.2.0 # fixed for now
printf "%s" "${version}"