#!/usr/bin/env bash
# Maloja publishes git tags but NO GitHub releases, so /releases/latest returns
# null here and this has to read /tags. Tag order from that endpoint is not
# semver-sorted, hence the explicit sort -V rather than taking .[0].
version=$(curl -L -sX GET "https://api.github.com/repos/krateng/maloja/tags?per_page=100" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[].name' | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
version="${version#*v}"
printf "%s" "${version}"
