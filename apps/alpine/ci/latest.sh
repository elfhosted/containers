#!/usr/bin/env bash
channel=$1
if [[ "${channel}" == "node" ]]; then
    version="20"
else
    version=$channel # in every other case, the channel _is_ the version
    # version=$(curl -s "https://registry.hub.docker.com/v2/repositories/library/alpine/tags?ordering=name&name=$channel" | jq --raw-output --arg s "$channel" '.results[] | select(.name | contains($s)) | .name'  | head -n1)
    # version="${version#*v}"
    # version="${version#*release-}"
fi
printf "%s" "${version}"


