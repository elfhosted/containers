#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "ui" ]]; then
  version=$(curl -sX GET https://api.github.com/repos/dan-online/autopulse/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
else
  version=$(curl -sX GET "https://api.github.com/repos/d3v1l1989/targeted-scans/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha[0:7]')
fi
printf "%s" "${version}"
