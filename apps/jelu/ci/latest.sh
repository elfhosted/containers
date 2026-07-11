#!/usr/bin/env bash
# Jelu tags releases as vX.Y.Z. Keep the upstream "v" prefix so the image tag,
# the git clone tag (Dockerfile `git clone -b ${VERSION}`), and the chart tag all
# match (same convention as grimmory). The fat jar is named jelu-<X.Y.Z>.jar
# (no prefix), so the Dockerfile locates it with `find` rather than hardcoding.
version=$(curl -sX GET "https://api.github.com/repos/bayang/jelu/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
printf "%s" "${version}"
