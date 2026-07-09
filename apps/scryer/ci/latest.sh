#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/scryer-media/scryer/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
# Upstream tags are prefixed "scryer-v" (e.g. scryer-v0.16.8)
version="${version#scryer-v}"
printf "%s" "${version}"
