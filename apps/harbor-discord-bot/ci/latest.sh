#!/usr/bin/env bash
# harbor-discord-bot: Harbor's Discord operations bot -- service status posts,
# bug reports, support tickets -- plus "Harbor Control", its admin dashboard.
#
# Source: https://github.com/Talal1011/harbor-discord-bot (PRIVATE).
#
# NOT A CATALOG APP. This is run for the Harbor maintainers to administer their
# own Discord, like the other harbor-* services here. It has no tenant-facing
# surface, no store product and no bundle, so the new-app workflow does not
# apply to it.
#
# ZURG_GH_CREDS is the credential, as for every other Harbor image. Note this
# repo lives under a PERSONAL account rather than harborstremio, so the token's
# access to it is a separate grant from its harbor-hosted access -- if that
# grant is ever lost, every call below returns empty, latest.sh emits an empty
# string, and action-image-build.yaml treats that as a hard build failure rather
# than tagging a null image. That is the intended failure.
#
# WHAT THIS EMITS, and why the v-prefix is kept. The value printed here becomes
# BOTH the --build-arg VERSION the Dockerfile checks out AND the image tag, so
# it has to be resolvable by git and legal as a Docker tag at the same time.
# Upstream tags read `v0.1.0`, which satisfies both, so it is emitted verbatim.
# Stripping the `v` -- the usual convention here -- would produce `0.1.0`, which
# is not a ref in that repo, and `git checkout` would fail after a clean clone.
# Renovate parses the v-prefixed form with the existing `^v?(?<major>...)` rule,
# so no new versioning rule is needed for this image.
#
# FALLBACK: main's short sha, covering the window between a commit landing and a
# release being cut. Slash-free, legal as a tag, resolvable by the Dockerfile's
# `git checkout`, and it moves when main moves, so a new commit triggers a
# rebuild on the next scheduled run. Same rationale as the other harbor images.
set -uo pipefail

repo="Talal1011/harbor-discord-bot"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

version="$(
  curl -fsSL -H "${auth_header}" \
    "https://api.github.com/repos/${repo}/releases/latest" \
  | jq -r '.tag_name // empty'
)"

if [[ -z "${version}" ]]; then
  version="$(
    curl -fsSL -H "${auth_header}" \
      "https://api.github.com/repos/${repo}/commits/main" \
    | jq -r '.sha[0:7] // empty'
  )"
fi

printf '%s' "${version}"
