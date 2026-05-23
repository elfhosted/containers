#!/usr/bin/env bash
# Fetch the latest version identifier for the postersplus image.
#
# We track the elfhosted/PostersPlus fork (not UmbraProjects upstream)
# because the fork holds our hosting-mode commits — env-var-gated
# backends for Postgres/Redis/S3, multi-replica leader election, the
# Prometheus /metrics endpoint, etc. Upstream gets these via PR; the
# fork rebases on upstream periodically.
#
# Channel:
#   main  →  latest commit on the fork's main branch (short SHA).
#            The fork doesn't tag releases yet; once it does, this can
#            switch to /releases/latest for a stable channel.
channel=$1

version=$(curl -sX GET "https://api.github.com/repos/elfhosted/PostersPlus/commits/main" \
  --header "Authorization: Bearer ${TOKEN}" \
  | jq --raw-output '.sha[0:7]')

printf "%s" "${version}"
