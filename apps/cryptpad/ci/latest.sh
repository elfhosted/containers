#!/usr/bin/env bash
# CryptPad tags releases as CalVer with no prefix, e.g. "2026.5.1"
version=$(curl -sX GET "https://api.github.com/repos/cryptpad/cryptpad/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
