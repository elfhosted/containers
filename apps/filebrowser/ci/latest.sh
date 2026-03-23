#!/usr/bin/env bash
channel=$1
version=$(curl -sX GET "https://api.github.com/repos/gtsteffaniak/filebrowser/releases?per_page=1" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].tag_name')
printf "%s" "${version}"
