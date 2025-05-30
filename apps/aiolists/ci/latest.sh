#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/SebastianMorel/AIOLists/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*CineSync-}"
printf "%s" "${version}"    

