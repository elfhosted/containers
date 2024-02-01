#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/geek-cookbook/torrentio.elfhosted.com/commits/${channel}" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
