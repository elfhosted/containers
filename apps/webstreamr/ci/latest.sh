#!/usr/bin/env bash
version=$(curl -sX GET "https://gitlab.com/api/v4/projects/webstreamr%2Fwebstreamr/releases" | jq --raw-output '.[0].tag_name')
printf "%s" "${version}"