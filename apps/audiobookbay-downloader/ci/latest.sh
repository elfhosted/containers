#!/usr/bin/env bash
version=$(curl -L -sX GET "https://api.github.com/repos/moonblade/Audiobookbay-Downloader/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"    



