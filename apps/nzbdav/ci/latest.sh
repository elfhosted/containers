#!/usr/bin/env bash

channel=$1

if [[ "${channel}" == "catalog-storage-offload" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/elfhosted/nzbdav/commits/feature/nzb-external-storage" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
else
    # main + dev build the community fork (nzbdav/nzbdav) from a pinned
    # FORK_REF in the Dockerfile, so the version is maintained here in
    # lockstep with that pin — NOT taken from the fork's latest release,
    # which would mislabel images the moment the fork tags a release we
    # haven't rebased onto yet.
    version="v0.8.0"
fi
printf "%s" "${version}"
