#!/usr/bin/env bash
version=$(curl -sX GET "https://repology.org/api/v1/projects/?search=deluge&inrepo=alpine_edge" | jq -r '.deluge | .[] | select((.repo == "alpine_edge" and .binname == "deluge")) | .version')
version="${version%%_*}"
version="${version%%-*}"
printf "%s" "${version}"
