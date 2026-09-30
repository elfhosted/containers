#!/usr/bin/env bash
# The repo is private, so the release lookup needs a credential.
version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/newznabproxy/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
printf "%s" "${version}"
