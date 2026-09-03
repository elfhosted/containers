#!/usr/bin/env bash
# elfhosted/mellon is private — auth via ZURG_GH_CREDS.
#
# Falls back to the main-branch sha when no release exists yet, because an empty
# version would be passed to `git clone -b` and fail with a much less obvious
# error than "there is no release".
version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/mellon/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')
if [[ -z "${version}" ]]; then
    version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/mellon/commits/main --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha[0:7] // empty')
fi
printf "%s" "${version}"
