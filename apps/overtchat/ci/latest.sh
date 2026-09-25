#!/usr/bin/env bash
# The repo also releases cli-v*, connector-v* and mobile-v* tags; only a plain
# vX.Y.Z tag is the server app (and has a matching overtchat-app image).
version=$(curl -L -sX GET "https://api.github.com/repos/yoloyash/overtchat/releases?per_page=30" --header "Authorization: Bearer ${TOKEN}" \
  | jq --raw-output '[.[] | select(.draft == false and .prerelease == false) | select(.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))][0].tag_name')
version="${version#*v}"
printf "%s" "${version}"
