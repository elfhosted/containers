#!/usr/bin/env bash
# version=$(curl -sX GET https://api.github.com/repos/debridmediamanager/zurg-testing/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
# version="${version#*release-}"
# printf "%s" "${version}"
printf "%s" "v0.9.3-hotfix.9"