#!/usr/bin/env bash

# The main channel is pinned to v3.9.0, the last GPL-3.0 release. v4.0.0
# changed the license, so move the pin only after reviewing a release's terms.
PINNED_VERSION="v3.9.0"

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -L -sX GET "https://api.github.com/repos/cedya77/aiometadata/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version="${PINNED_VERSION}"
fi
printf "%s" "${version}"
