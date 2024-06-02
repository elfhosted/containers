#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/jellyfin/jellyfin/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*v}"
version="${version#*release-}"
# printf "%s" "${version}"
print "v6.1.5.231022"