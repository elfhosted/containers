#!/usr/bin/env bash
# Ghostfolio tags GitHub releases as bare semver (e.g. 3.24.0, no "v" prefix).
# The official multi-arch image on Docker Hub is tagged with the same string,
# which the Dockerfile consumes via the VERSION build-arg. Our images publish
# as ghostfolio:rolling and ghostfolio:{version}.
version=$(curl -sX GET "https://api.github.com/repos/ghostfolio/ghostfolio/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
