#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/meisnate12/Plex-Meta-Manager/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*release-}"
printf "%s" "${version}"