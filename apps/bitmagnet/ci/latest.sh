#!/usr/bin/env bash
# Track the most recently published release tag (stable OR prerelease).
# Upstream has gone 15+ months without a stable release while shipping beta
# improvements, so /releases/latest (stable-only) leaves us pinned to v0.10.0.
version=$(curl -sX GET 'https://api.github.com/repos/bitmagnet-io/bitmagnet/releases?per_page=1' --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].tag_name')
version="${version#*release-}"
printf "%s" "${version}"
