#!/usr/bin/env bash
version="$(curl -sX GET "https://api.github.com/repos/Casvt/Kapowarr/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')"
version="${version#*V}"
printf "%s" "${version}"