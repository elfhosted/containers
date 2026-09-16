#!/usr/bin/env bash
version=$(curl -L -sX GET "https://api.github.com/repos/wealthfolio/wealthfolio/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
