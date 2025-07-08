#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/anmol210202/rating-aggregator-/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
printf "%s" "${version}"