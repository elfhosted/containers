#!/usr/bin/env bash
# elfhosted/litterbox is public — auth via the workflow's default TOKEN.
# `// empty` ensures we return "" rather than "null" during the pre-
# first-release window, which CI then handles gracefully.
version=$(curl -sX GET https://api.github.com/repos/elfhosted/litterbox/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
