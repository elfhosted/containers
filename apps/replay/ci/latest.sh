#!/usr/bin/env bash
# elfhosted/replay is a public repo, but ZURG_GH_CREDS is used consistently
# across our own sources so the call is authenticated and not rate-limited.
# `// empty` returns "" rather than "null" before the first release exists,
# which CI handles gracefully.
version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/replay/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
