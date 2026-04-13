#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/elfhosted/jackettio-internal/commits/main" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
printf "%s" "${version}"
