#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/Pukabyte/torrentio-scraper-sh/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
