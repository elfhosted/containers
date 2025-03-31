#!/usr/bin/env bash
channel=$1

if [[ "${channel}" == "dev" ]]; then
    # fake it
    version=$(curl -sX GET "https://radarr.servarr.com/v1/update/master/changes?os=linux&runtime=netcore" | jq --raw-output '.[0].version' 2>/dev/null)
else
    version=$(curl -sX GET "https://radarr.servarr.com/v1/update/${channel}/changes?os=linux&runtime=netcore" | jq --raw-output '.[0].version' 2>/dev/null)
fi

version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"