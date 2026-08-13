#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "ui" ]]; then
  version=$(curl -L -sX GET https://api.github.com/repos/dan-online/autopulse/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
else
  version=$(curl -L -sX GET "https://api.github.com/repos/d3v1l1989/targeted-scans/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha[0:7]')
fi
printf "%s" "${version}"

# rebuild nudge 2026-08-02: pick up containers-private autopulse patch 0002
# (webhook 500->200 retry-loop fix, containers-private#118). No behaviour change here.
