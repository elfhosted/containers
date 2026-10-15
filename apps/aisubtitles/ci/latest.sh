#!/usr/bin/env bash
# Upstream publishes no releases or tags, so track commits on main.
version=$(curl -L -sX GET "https://api.github.com/repos/luizsilva-dev/stremio-ai-subtitles/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')

printf "%s" "${version}"
