#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/MediaBrowser/Emby.Releases/releases --header "Authorization: Bearer ${TOKEN}" | jq -r '.[] | select(.prerelease == true) | .tag_name' | head -n 1)
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
