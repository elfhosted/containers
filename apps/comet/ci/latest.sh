#!/usr/bin/env bash
channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/elfhosted/comet/commits/add-readonly-replica-support" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha')
else
    version=$(curl -sX GET https://api.github.com/repos/g0ldyy/comet/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
fi
printf "%s" "${version}"   