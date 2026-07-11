#!/usr/bin/env bash
# PinePods cuts GitHub releases tagged without a "v" prefix (e.g. 0.9.0), and
# publishes matching multi-arch Docker Hub tags (madeofpendletonwool/pinepods:0.9.0).
# Our Dockerfile bases off that upstream image, so the release tag drives the build.
version=$(curl -sX GET "https://api.github.com/repos/madeofpendletonwool/PinePods/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
