#!/usr/bin/env bash

channel=$1
version="$(curl -sX GET "https://api.github.com/repos/rivenmedia/riven-frontend/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')"
printf "%s" "${version}"
