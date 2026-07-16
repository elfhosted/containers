#!/usr/bin/env bash
# Upstream tags are unprefixed semver (e.g. 7.1.1); the ${version#*v} strip is a
# harmless no-op here but kept for consistency with the other apps.
version=$(curl -sX GET "https://api.github.com/repos/spiral-project/ihatemoney/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
