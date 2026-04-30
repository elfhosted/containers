#!/usr/bin/env bash
# Returns the latest release tag, or empty string if no release exists yet.
# Empty string causes CI to skip the build (vs `null` which makes
# `git clone -b null` fatal in the Dockerfile).
version=$(curl -sX GET https://api.github.com/repos/elfhosted/catbox/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name // empty')
version="${version#*v}"
printf "%s" "${version}"
