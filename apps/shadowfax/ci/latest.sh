#!/usr/bin/env bash
# elfhosted/shadowfax is private — auth via ZURG_GH_CREDS.
version=$(curl -sX GET https://api.github.com/repos/elfhosted/shadowfax/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
