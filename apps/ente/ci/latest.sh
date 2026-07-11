#!/usr/bin/env bash
# The Ente "museum" server has no release tags of its own (upstream only tags
# per-client releases like photos-v* / auth-v*); the server is continuously
# built from main. Track the short commit SHA of the main branch.
version=$(curl -sX GET "https://api.github.com/repos/ente/ente/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha[0:7]')
printf "%s" "${version}"
