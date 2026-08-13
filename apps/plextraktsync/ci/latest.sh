#!/usr/bin/env bash
version=$(curl -L -sX GET https://api.github.com/repos/Taxel/PlexTraktSync/tags --header "Authorization: Bearer ${TOKEN}" | grep '"name"' | head -n 1 | sed 's/.*: "\(.*\)",/\1/')
printf "%s" "${version}"
