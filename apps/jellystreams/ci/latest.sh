#!/usr/bin/env bash
# `jellystreams` is our own code, in the private repo elfhosted/jellystreams,
# where release-please cuts the tags. Auth via ZURG_GH_CREDS.
#
# It reads /releases/latest, not /tags: release-please creates both, but only a
# published RELEASE is visible here, and that is deliberate -- a tag pushed by
# hand should not start a rebuild.
#
# An empty result means the lookup failed (rate-limit, outage, a token that
# cannot see the repo) rather than "no version". fetch.sh treats empty as
# "skip", so a failure here costs a nightly rebuild rather than pushing a wrong
# tag. Same shape as balrog, debridge, shadowfax and zyclops.
version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/jellystreams/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
