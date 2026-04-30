#!/usr/bin/env bash
# elfhosted/catbox is private — auth via ZURG_GH_CREDS (which has org read
# access) rather than the public-only TOKEN.
# `// empty` ensures we return "" rather than "null" on the rare
# pre-first-release window, which CI then handles gracefully.
version=$(curl -sX GET https://api.github.com/repos/elfhosted/catbox/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
