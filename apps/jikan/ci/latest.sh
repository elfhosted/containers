#!/usr/bin/env bash
# jikan-me/jikan-rest is public; resolve the latest release tag (e.g. v4.2.4).
# The tag matches the docker.io/jikanme/jikan-rest tag the mirror Dockerfile pulls.
version=$(curl -sX GET https://api.github.com/repos/jikan-me/jikan-rest/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
printf "%s" "${version}"
