#!/usr/bin/env bash
# Baikal tags its GitHub releases without a "v" prefix (e.g. "0.11.1"), so the
# ${version#*v} strip below is a harmless no-op that also covers any future
# "v"-prefixed tag. The resulting version is passed to the Dockerfile as
# ARG VERSION and used as the git clone ref.
version=$(curl -sX GET "https://api.github.com/repos/sabre-io/Baikal/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
