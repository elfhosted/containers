#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "dev" ]]; then
    # fake it
    version=$(curl -sX GET "https://services.sonarr.tv/v1/download/main?version=4.0" | jq --raw-output '.version')
else
    version=$(curl -sX GET "https://services.sonarr.tv/v1/download/${channel}?version=4.0" | jq --raw-output '.version')
fi

version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
