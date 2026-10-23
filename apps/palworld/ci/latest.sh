#!/usr/bin/env bash
# VERSION here is the thijsvanloef/palworld-server-docker image release (e.g.
# 2.7.2, published to Docker Hub as v2.7.2 -- the Dockerfile re-adds the v).
# It is NOT the Palworld version: the game server is downloaded from Steam at
# boot, and whatever Steam serves is the only version current clients can join,
# so there is nothing to pin. See the Dockerfile for why that distinction is
# load-bearing rather than incidental.
curl_args=()
for var in TOKEN GITHUB_TOKEN GH_TOKEN; do
  if [[ -n "${!var:-}" ]]; then
    curl_args=(-H "Authorization: Bearer ${!var}")
    break
  fi
done

# Upstream may publish a GitHub release before the matching Docker Hub image tag
# exists. The private Dockerfile extends thijsvanloef/palworld-server-docker:vX,
# so only return a release whose Docker Hub manifest is actually available.
mapfile -t tags < <(curl -fsSL "${curl_args[@]}" \
  "https://api.github.com/repos/thijsvanloef/palworld-server-docker/releases?per_page=20" \
  | jq -r '.[] | select(.draft == false and .prerelease == false) | .tag_name')

for tag in "${tags[@]}"; do
  version="${tag#v}"
  err="$(mktemp)"
  if docker manifest inspect "thijsvanloef/palworld-server-docker:v${version}" >/dev/null 2>"${err}"; then
    rm -f "${err}"
    printf "%s" "${version}"
    exit 0
  fi
  if grep -qiE 'no such manifest|manifest unknown' "${err}"; then
    rm -f "${err}"
    continue
  fi
  cat "${err}" >&2
  rm -f "${err}"
  exit 1
done

echo "No thijsvanloef/palworld-server-docker image found for recent upstream releases" >&2
exit 1
