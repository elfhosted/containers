#!/usr/bin/env bash
channel=$1

LATEST_YTDLP=$(curl -sX GET https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')

if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/DialmasterOrg/Youtarr/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version="$(curl -sX GET "https://api.github.com/repos/DialmasterOrg/Youtarr/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')"
fi
printf "%s" "${version}-${LATEST_YTDLP}"   
