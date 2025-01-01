#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/reposcalibrain/calibre-web-automated-book-downloader/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"