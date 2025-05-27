#!/usr/bin/env bash
version="$(curl -s "https://gitlab.com/api/v4/projects/storyteller-platform%2Fstoryteller/repository/tags" | jq -r '.[].name' | grep '^web-' | sort -Vr | head -n 1)"
version="${version#*web-}"
printf "%s" "${version}"
