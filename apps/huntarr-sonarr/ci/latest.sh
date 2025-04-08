#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/plexguide/Huntarr-Sonarr/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*release-}"
printf "%s" "${version}"
