#!/usr/bin/env bash
# Kan publishes every release as a GitHub "prerelease", so /releases/latest
# returns 404. Take the newest non-draft release with a plain semver tag.
version=$(curl -L -sX GET "https://api.github.com/repos/kanbn/kan/releases?per_page=20" --header "Authorization: Bearer ${TOKEN}" \
  | jq --raw-output '[.[] | select(.draft == false) | select(.tag_name | test("^v?[0-9]+\\.[0-9]+\\.[0-9]+$"))][0].tag_name')
version="${version#*v}"
printf "%s" "${version}"
