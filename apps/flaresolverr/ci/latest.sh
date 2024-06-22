#!/usr/bin/env bash
# version=$(curl -sX GET "https://api.github.com/repos/21hsmw/FlareSolverr/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')

version="$(curl -sX GET "https://api.github.com/repos/FlareSolverr/FlareSolverr/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
