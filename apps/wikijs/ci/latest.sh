#!/usr/bin/env bash
set -euo pipefail

# Wiki.js publishes 3.0.0-beta.* releases that may not be marked prerelease.
# Stable hosted builds stay on the 2.x line until the private overlay is
# explicitly ported/tested for 3.x.
token="${TOKEN:-}"
if [ -z "$token" ]; then token="${GITHUB_TOKEN:-}"; fi
if [ -z "$token" ]; then token="${GH_TOKEN:-}"; fi

version=""
for page in $(seq 1 10); do
  curl_args=(-fsSL "https://api.github.com/repos/requarks/wiki/releases?per_page=100&page=${page}")
  if [ -n "$token" ]; then
    curl_args+=(-H "Authorization: token ${token}")
  fi
  page_version=$(curl "${curl_args[@]}"     | jq --raw-output '[.[] | select((.tag_name | ltrimstr("v") | startswith("2.")) and (.tag_name | test("beta|alpha|rc|preview"; "i") | not))][0].tag_name // empty')
  if [ -n "$page_version" ]; then
    version="$page_version"
    break
  fi
done

version="${version#v}"
if [ -z "$version" ] || [ "$version" = "null" ]; then
  echo "failed to resolve stable Wiki.js 2.x release" >&2
  exit 1
fi
printf "%s" "$version"
