#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/godver3/phalanx_db_hyperswarm/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"