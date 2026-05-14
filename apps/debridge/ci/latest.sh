#!/usr/bin/env bash
# elfhosted/debridge is private — auth via ZURG_GH_CREDS.
version=$(curl -sX GET https://api.github.com/repos/elfhosted/debridge/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
