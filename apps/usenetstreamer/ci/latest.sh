#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/sanket9225/usenetstreamer/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
