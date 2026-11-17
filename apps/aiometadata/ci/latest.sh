#!/usr/bin/env bash

# The main channel is pinned to a reviewed release. Move the pin only after
# reviewing a release's license terms.
PINNED_VERSION="v4.0.0"

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -L -sX GET "https://api.github.com/repos/cedya77/aiometadata/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    version="${PINNED_VERSION}"
fi
printf "%s" "${version}"
