#!/usr/bin/env bash
# BookStack tags releases as vYY.MM.patch (v26.05.4); the leading v is stripped
# for the image tag but re-added when fetching the source archive.
version=$(curl -L -sX GET "https://api.github.com/repos/BookStackApp/BookStack/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
