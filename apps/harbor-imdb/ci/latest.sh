#!/usr/bin/env bash
# harbor-imdb: one of the nine Harbor backend services.
#
# Source: https://github.com/harborstremio/harbor-hosted (PRIVATE), at
# services/harbor-imdb/src. These images integrate with ElfHosted-internal
# services (EMDB, ElfCache), so they are ElfHosted artifacts and are not
# self-hostable.
#
# ZURG_GH_CREDS is the credential, and it is CONFIRMED to work here: the account
# it belongs to holds write access on harborstremio/harbor-hosted, so the token
# reads it despite the different org. The name records what it was created for,
# not what it is scoped to. No Harbor-specific secret is needed. Every call below
# returns empty without read access, which makes latest.sh emit an empty string,
# which action-image-build.yaml deliberately treats as a hard build failure
# rather than tagging a null image.
#
# WHAT THIS EMITS, and why it is a git ref rather than a bare semver: the value
# printed here becomes both the --build-arg VERSION the Dockerfile checks out
# AND the image tag. So it has to be resolvable by git and legal as a Docker
# tag at the same time.
#
# PREFERRED: the newest per-component release-please tag. harbor-hosted's
# release-please-config.json sets include-component-in-tag, include-v-in-tag and
# tag-separator "-", so tags read harbor-imdb-v0.1.0. That form is a valid git ref
# and a valid Docker tag, so it is emitted verbatim.
#
# FALLBACK: no harbor-imdb-v* tag exists yet, because the vendoring PR (#1) is
# unmerged and release-please has never run against this repo. So the fallback
# is the SHORT SHA of the vendoring branch head. Two more obvious fallbacks were
# rejected:
#
#   * the branch name feat/vendored-services-and-deployment contains a SLASH,
#     and this value is interpolated straight into the image tag, where a slash
#     is illegal. The build would clone fine and then fail on push.
#   * main does not yet contain services/ at all, so a build from main resolves
#     to a real ref and then fails at the first COPY.
#
# A short sha is slash-free, legal as a tag, resolvable by the `git checkout` in
# the Dockerfile, and it moves when the branch moves, so a new commit triggers a
# rebuild on the next scheduled run. Same rationale as apps/docs-internal.
#
# main's short sha is the last resort, so that this keeps working after PR #1
# merges and before the first release-please run.
set -uo pipefail

repo="harborstremio/harbor-hosted"
component="harbor-imdb"
branch="feat/vendored-services-and-deployment"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

# Newest harbor-imdb-v* tag. Sorted by version rather than trusting the API's
# ordering, and filtered to x.y.z so a stray tag cannot win.
version="$(
  curl -fsSL -H "${auth_header}" \
    "https://api.github.com/repos/${repo}/tags?per_page=100" \
  | jq -r --arg c "${component}-v" '.[].name | select(startswith($c))' \
  | sed "s/^${component}-v//" \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
  | sort -V \
  | tail -n1 \
  | sed "s/^/${component}-v/"
)"

if [[ -z "${version}" ]]; then
  version="$(
    curl -fsSL -H "${auth_header}" \
      "https://api.github.com/repos/${repo}/commits/${branch}" \
    | jq -r '.sha[0:7] // empty'
  )"
fi

if [[ -z "${version}" ]]; then
  version="$(
    curl -fsSL -H "${auth_header}" \
      "https://api.github.com/repos/${repo}/commits/main" \
    | jq -r '.sha[0:7] // empty'
  )"
fi

printf '%s' "${version}"
