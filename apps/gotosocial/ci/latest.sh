#!/usr/bin/env bash
set -euo pipefail

repo="superseriousbusiness/gotosocial"
url="https://registry.hub.docker.com/v2/repositories/${repo}/tags/?page_size=100"

tags=""
while [ -n "${url}" ]; do
  json=$(curl -sS "${url}")
  tags+=$'\n'$(jq -r '.results[].name' <<< "${json}")
  url=$(jq -r '.next // empty' <<< "${json}")
done

# Filter to semantic version-like tags (allow optional pre-release)
versions=$(printf "%s\n" "${tags}" | grep -E '^[0-9]+(\.[0-9]+){2}(-[0-9A-Za-z.-]+)?$' || true)

# Prefer stable (no pre-release) x.y.z
stable=$(printf "%s\n" "${versions}" | grep -E '^[0-9]+(\.[0-9]+){2}$' || true)

if [ -n "${stable}" ]; then
  list="${stable}"
else
  list="${versions}"
fi

highest=$(printf "%s\n" "${list}" | sort -V | tail -1)

printf "%s" "${highest}"