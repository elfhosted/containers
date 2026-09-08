#!/usr/bin/env bash
# PrivateBin tags releases without a "v" prefix (2.0.6), which is also the tag
# the source archive is fetched by, so no rewriting is needed.
version=$(curl -L -sX GET "https://api.github.com/repos/PrivateBin/PrivateBin/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
