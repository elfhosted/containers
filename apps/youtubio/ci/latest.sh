#!/usr/bin/env bash
channel=$1

LATEST_YOUTUBIO=$(curl -sX GET https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')

if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/xXCrash2BomberXx/YouTubio/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/xXCrash2BomberXx/YouTubio/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}-${LATEST_YOUTUBIO}"   