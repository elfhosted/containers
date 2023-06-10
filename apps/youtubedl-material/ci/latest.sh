#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/Tzahi12345/YoutubeDL-Material/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
