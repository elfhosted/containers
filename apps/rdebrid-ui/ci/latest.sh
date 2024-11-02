#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/tgdrive/rdebrid-ui/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
version="${version#*release-}"
printf "%s" "${version}"
