#!/usr/bin/env bash
version=$(curl -sX GET "https://repology.org/api/v1/projects/?search=rclone&inrepo=alpine_edge" | jq -r '.rclone | .[] | select((.repo == "alpine_edge" and .binname == "rclone")) | .version')
version="${version%%_*}"
version="${version%%-*}"
# printf "%s" "${version}"
printf "%s" "1.65.1"
