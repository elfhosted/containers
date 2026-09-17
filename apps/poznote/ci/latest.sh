#!/usr/bin/env bash
# Upstream tags have no "v" prefix (e.g. 6.87.0); releases/latest skips the -beta prereleases
version=$(curl -L -sX GET "https://api.github.com/repos/timothepoznanski/poznote/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
