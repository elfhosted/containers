#!/usr/bin/env bash
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET https://api.github.com/repos/debridmediamanager/zurg/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
    print 'v0.10.0-rc.1'
else
    version=$(curl -sX GET https://api.github.com/repos/debridmediamanager/zurg-testing/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
    version="${version#*release-}"
    printf "%s" "${version}"
fi
