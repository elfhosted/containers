#!/usr/bin/env bash
# GitHub's releases/latest excludes prereleases, which matters here: Wiki.js
# publishes 3.0.0-beta.* continuously while 2.x remains the stable line, so
# /releases would return a beta and /releases/latest correctly returns 2.5.314.
version=$(curl -L -sX GET "https://api.github.com/repos/requarks/wiki/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
