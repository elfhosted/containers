#!/usr/bin/env bash
version=$(curl -s "https://api.github.com/repos/bluesky-social/atproto/releases" --header "Authorization: Bearer ${TOKEN}"  | jq -r '[.[] | select((.name // "" | contains("pds")) or (.tag_name | contains("pds")))][0].tag_name')
version="${version#*@atproto/pds@}"
printf "%s" "${version}"
