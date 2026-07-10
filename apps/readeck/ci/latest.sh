#!/usr/bin/env bash
# Readeck lives on Codeberg (Gitea API) - no auth token required
version=$(curl -sX GET "https://codeberg.org/api/v1/repos/readeck/readeck/releases/latest" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
