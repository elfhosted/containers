#!/usr/bin/env bash

version=$(curl -sX GET "https://api.github.com/repos/mesosphere/traefik-forward-auth/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
