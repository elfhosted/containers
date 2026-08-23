#!/usr/bin/env bash
# Koito tags GitHub releases as vX.Y.Z and publishes matching Docker Hub tags
# with the "v" retained (gabehf/koito:v0.3.2). We strip the "v" here because the
# emitted value becomes our own image tag, and the Dockerfile puts it back when
# it resolves the upstream base.
#
# Do NOT switch this to the "dev" tag or to /tags: upstream marks the project
# unstable and warns that main can be unusable, so only cut releases are safe.
version=$(curl -L -sX GET "https://api.github.com/repos/gabehf/Koito/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
