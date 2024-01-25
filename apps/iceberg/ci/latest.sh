#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/dreulavelle/iceberg/commits/dev" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
