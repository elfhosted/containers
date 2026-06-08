#!/usr/bin/env bash
# docs-internal builds from the (private) docs.elfhosted.com repo's main branch.
# Use the latest main commit sha as the version, so a docs change triggers a
# rebuild on the next scheduled run. ZURG_GH_CREDS must have read access to the
# private docs repo.
version=$(curl -sX GET "https://api.github.com/repos/elfhosted/docs.elfhosted.com/commits/main" --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.sha[0:7]')
printf "%s" "${version}"
