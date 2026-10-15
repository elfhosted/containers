#!/usr/bin/env bash
# Housetrained publishes no release tags yet, so track the default branch's
# head commit (short sha). The Dockerfile clones and checks out this sha.
version=$(curl -L -sX GET "https://api.github.com/repos/viciousnemesis/housetrained/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha[0:7]')
printf "%s" "${version}"
