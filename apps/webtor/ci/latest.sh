#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/webtor-io/self-hosted/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
printf "%s" "${version}"