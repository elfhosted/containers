#!/usr/bin/env bash
version=$(curl -sX GET "https://api.github.com/repos/ceresimaging/csi-rclone/commits/master" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
version="${version#*release-}"
printf "%s" "${version}"
