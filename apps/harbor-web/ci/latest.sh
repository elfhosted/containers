#!/usr/bin/env bash
# harbor-web: Harbor's Vite/React SPA, built static and served by nginx.
#
# Source: https://github.com/harborstremio/harbor — PUBLIC and MIT. Note that this
# is a DIFFERENT repo from the nine harbor-* backend services, which come from the
# private harborstremio/harbor-hosted. Consequences for this file:
#
#   * No credential is needed. ZURG_GH_CREDS is exported by upstream.sh and is used
#     below ONLY to raise the anonymous 60-requests-per-hour rate limit, never for
#     access. Every call degrades gracefully if it is empty, which is why the header
#     is assembled conditionally rather than sent with an empty Bearer value — a
#     literal "Authorization: Bearer " is rejected as malformed and would turn a
#     missing secret into a hard failure on a public repo.
#   * The version is a plain release tag, not a release-please component tag.
#
# WHAT THIS EMITS, and why a git ref rather than a bare semver: the value printed
# here becomes BOTH the --build-arg VERSION the Dockerfile checks out AND the image
# tag. So it has to be resolvable by `git checkout` and legal as a Docker tag at the
# same time.
#
# PREFERRED: the tag_name of the latest GitHub RELEASE.
#
# releases/latest and not the tags list, and this is the whole reason this file is
# not three lines. Harbor's tag names do not sort: the current latest release is
# `V0.9.21` — CAPITAL V — while every earlier one is lowercase `v0.9.20` and down.
# Worse, the release notes for V0.9.21 read "everything from the 0.9.49-0.9.96 betas,
# rolled into stable", and package.json at that tag says 0.9.87. So the stable line
# and the internal version are separate number spaces and `sort -V` over tag names
# would confidently pick the wrong one. GitHub's releases/latest endpoint returns
# what the maintainer marked latest, which is the only authority here. Mixed case is
# fine for a Docker TAG (only repository NAMES must be lowercase).
#
# FALLBACK 1: the newest v-prefixed x.y.z tag by version sort. Used only if the
# releases endpoint fails or the repo has no published release. Restricted to the
# lowercase `v` form on purpose: that is the shape 20+ historical tags use, and
# mixing the capital-V outlier into a `sort -V` is exactly the bug described above.
#
# FALLBACK 2: main's short sha. Slash-free, legal as a tag, resolvable by the
# Dockerfile's `git checkout --detach`, and it moves when main moves so a new commit
# triggers a rebuild on the next scheduled run. Same rationale as apps/harbor-tvdb.
#
# An empty result is a HARD BUILD FAILURE by design: action-image-build.yaml refuses
# to tag a null image, because a bogus label can never match on the next schedule
# tick and would churn the :rolling digest forever. So never let this print nothing,
# and never "fix" a failure here by emitting a placeholder.
set -uo pipefail

repo="harborstremio/harbor"

# Only send an Authorization header if we actually have a token.
curl_args=(-fsSL)
if [[ -n "${ZURG_GH_CREDS:-}" ]]; then
  curl_args+=(-H "Authorization: Bearer ${ZURG_GH_CREDS}")
fi

version="$(
  curl "${curl_args[@]}" "https://api.github.com/repos/${repo}/releases/latest" \
  | jq -r '.tag_name // empty'
)"

if [[ -z "${version}" ]]; then
  version="$(
    curl "${curl_args[@]}" "https://api.github.com/repos/${repo}/tags?per_page=100" \
    | jq -r '.[].name | select(startswith("v"))' \
    | sed 's/^v//' \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V \
    | tail -n1 \
    | sed 's/^/v/'
  )"
fi

if [[ -z "${version}" ]]; then
  version="$(
    curl "${curl_args[@]}" "https://api.github.com/repos/${repo}/commits/main" \
    | jq -r '.sha[0:7] // empty'
  )"
fi

printf '%s' "${version}"
