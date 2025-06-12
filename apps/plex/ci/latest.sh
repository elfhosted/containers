#!/usr/bin/env bash
channel=$1

json=$(curl -sX GET 'https://plex.tv/api/downloads/5.json')

if [[ "${channel}" == "stable" ]]; then
    version=$(echo "$json" | jq -r '.computer.Linux.releases[] | select(.channel == "public") | .version' | head -n1)
elif [[ "${channel}" == "beta" ]]; then
    version=$(echo "$json" | jq -r '.computer.Linux.releases[] | select(.channel == "plexpass") | .version' | head -n1)
fi

version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
