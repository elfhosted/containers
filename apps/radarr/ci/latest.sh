#!/usr/bin/env bash
channel=$1
version=$(curl -sX GET "https://radarr.servarr.com/v1/update/${channel}/changes?os=linux&runtime=netcore" | jq --raw-output '.[0].version' 2>/dev/null)
printf "%s" "${version}"
