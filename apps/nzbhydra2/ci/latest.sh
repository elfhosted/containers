#!/usr/bin/env bash

channel="${1}"

# proxy.patch does not apply to upstream 9.3.2 or later (IndexerWebAccess,
# WebAccess and HydraOkHttp3ClientHttpRequestFactory were refactored). Until it
# is rebased, the proxy channel stays on the release its running image is
# built from, so a rebuild changes only what the patch changes.
if [[ "${channel}" == "proxy" ]]; then
    printf "%s" "9.1.1"
    exit 0
fi

version=$(curl -L -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].tag_name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
