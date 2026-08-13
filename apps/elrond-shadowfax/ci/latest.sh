#!/usr/bin/env bash
version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/elrond/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
printf "%s" "${version}"
