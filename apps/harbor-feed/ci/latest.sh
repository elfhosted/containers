#!/usr/bin/env bash
set -uo pipefail

repo="harborstremio/harbor-hosted"
component="harbor-feed"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

tags=""
page=1
while [ "${page}" -le 10 ]; do
  chunk="$(
    curl -fsSL -H "${auth_header}" \
      "https://api.github.com/repos/${repo}/tags?per_page=100&page=${page}" \
    | jq -r '.[].name' 2>/dev/null
  )"
  [ -z "${chunk}" ] && break
  tags="${tags}${chunk}
"
  page=$((page + 1))
done

version="$(
  printf '%s' "${tags}" \
  | grep -E "^${component}-v[0-9]+\.[0-9]+\.[0-9]+$" \
  | sed "s/^${component}-v//" \
  | sort -V \
  | tail -n1 \
  | sed "s/^/${component}-v/"
)"

if [ -z "${version}" ]; then
  echo "no ${component}-v* tag found in ${repo} (credential, API, or genuinely none)" >&2
  exit 1
fi

printf '%s' "${version}"
