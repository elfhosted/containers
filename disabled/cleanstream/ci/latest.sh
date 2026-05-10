#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/ameen-roayan/stremio-cleanstream/commits/main" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/ameen-roayan/stremio-cleanstream/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"   