#!/usr/bin/env bash
# GitHub's releases/latest excludes prereleases, so this returns the newest
# STABLE tag (v4.1.2) and skips the abandoned v5.0.0-beta.* line. The "v"
# prefix is kept verbatim (grimmory pattern): the image tag, the clone tag in
# the Dockerfile (git clone -b ${VERSION}), and the chart tag all stay in sync.
version=$(curl -sX GET "https://api.github.com/repos/monicahq/monica/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
printf "%s" "${version}"
