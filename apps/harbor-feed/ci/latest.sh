#!/usr/bin/env bash
# harbor-feed: the six consensus-feed builders (home hero Top 10, anime hero,
# award winners, people rank) that generate the static JSON harbor.site serves.
#
# Source: https://github.com/harborstremio/harbor-hosted (PRIVATE), at
# services/harbor-feed/src.
#
# WHY THIS EXISTS: these generators were left on the retiring VPS when the apex
# static origin moved to Kubernetes, so the box kept producing fresh files that
# no longer reached the edge and every feed has served a frozen copy since
# 2026-07-31. Nothing rebuilds them on this side until this image does.
#
# ZURG_GH_CREDS is the credential, as for every other Harbor image.
#
# EMITTED VERBATIM, component prefix and all: this value is BOTH the --build-arg
# VERSION the Dockerfile checks out AND the image tag, so it has to be a valid
# git ref and a legal Docker tag at once. release-please cuts
# harbor-feed-v<semver> from harbor-hosted, which satisfies both.
#
# Renovate reads this shape through the component-regex rule in infra's
# renovate.json5; harbor-feed must be added to that rule's matchPackageNames, or
# it will silently never be bumped.
set -uo pipefail

repo="harborstremio/harbor-hosted"
component="harbor-feed"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

# PAGINATED. harbor-hosted is a release-please monorepo cutting one tag per
# component, and tag order is neither date- nor semver-guaranteed, so a single
# per_page=100 page will eventually stop containing harbor-feed's tags and this
# would silently pin a stale version.
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

# FAIL LOUDLY. Without this the pipeline's failure is invisible: a bad
# credential or an API blip prints nothing and exits 0. The build workflow does
# refuse a null tag, but its message says only "resolved empty" and not why.
if [ -z "${version}" ]; then
  echo "no ${component}-v* tag found in ${repo} (credential, API, or genuinely none)" >&2
  exit 1
fi

printf '%s' "${version}"
