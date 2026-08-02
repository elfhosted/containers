#!/usr/bin/env bash
# harbor-web: Harbor's Vite/React SPA, built static and served by nginx.
#
# TRACKS A BRANCH, NOT A RELEASE, and that is deliberate. Harbor's stable line is
# cut from `stable-branch` (DEPLOY-HANDOFF.md section 5: a stable release is
# created by cloning beta-branch at release time). The branch carries the
# configurable VITE_HARBOR_*_BASE endpoints that our tenant hosting needs and that
# no published release has yet -- releases/latest is still V0.9.21 from 11 July,
# which predates all of it.
#
# CONSEQUENCE, stated plainly: builds follow whatever is newest on that branch, so
# they are NOT reproducible from this file alone. The emitted value is the short
# SHA, which is legal as a Docker tag and resolvable by `git checkout --detach`,
# and it MOVES when the branch moves -- so a new commit upstream produces a new
# image on the next scheduled run, with no action here. That is the intent.
#
# The digest is what pins a deployment; see the HelmRelease/values, which carry
# tag@sha256 rather than trusting this to be stable.
#
# An empty result is a HARD BUILD FAILURE by design: action-image-build.yaml
# refuses to tag a null image.
set -uo pipefail

repo="harborstremio/harbor"
branch="stable-branch"

curl_args=(-fsSL)
if [[ -n "${ZURG_GH_CREDS:-}" ]]; then
    curl_args+=(-H "Authorization: Bearer ${ZURG_GH_CREDS}")
fi

version="$(
  curl "${curl_args[@]}" "https://api.github.com/repos/${repo}/commits/${branch}" \
  | jq -r '.sha[0:7] // empty'
)"

printf '%s' "${version}"
