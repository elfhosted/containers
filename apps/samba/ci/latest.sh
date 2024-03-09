#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/crazy-max/docker-samba/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*v}"
version="${version#*release-}"
version="${version%-r0}"
version="${version%-r1}"
printf "%s" "${version}"
