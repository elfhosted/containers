#!/usr/bin/env bash
# elfhosted/newznabproxy is private — auth via ZURG_GH_CREDS (which has org
# read access) rather than the public-only TOKEN. `// empty` returns "" rather
# than "null" if no release exists, which CI handles gracefully.
version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/newznabproxy/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
