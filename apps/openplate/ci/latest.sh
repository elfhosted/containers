#!/usr/bin/env bash
# The repo also publishes core-v* and inference releases, so /releases/latest can
# name a component we don't build. Take the newest app release (plain v<semver>).
version=$(curl -L -sX GET "https://api.github.com/repos/LowCarbCheck/openplate/releases?per_page=30" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '[.[] | select(.draft == false and .prerelease == false) | .tag_name | select(test("^v[0-9]"))][0]')
version="${version#*v}"
printf "%s" "${version}"
