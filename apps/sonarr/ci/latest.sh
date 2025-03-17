#!/usr/bin/env bash
version=$(curl -sX GET "https://services.sonarr.tv/v1/download/${channel}?version=4.0" | jq --raw-output '.version')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
