#!/usr/bin/env bash
set -euo pipefail

channel="${1:-stable}"
repo="openclaw/openclaw"

gh_curl() {
  if [[ -n "${TOKEN-}" ]]; then
    curl -fsSL -H "Authorization: Bearer ${TOKEN}" "$@"
  else
    curl -fsSL "$@"
  fi
}

get_commit_sha() {
  local ref="$1"
  local encoded_ref
  encoded_ref="$(printf '%s' "$ref" | jq -sRr @uri)"

  gh_curl \
    "https://api.github.com/repos/${repo}/commits?sha=${encoded_ref}" \
  | jq -r '.[0].sha'
}

case "$channel" in
  dev)
    version="$(get_commit_sha main)"
    ;;
  *)
    version="$(
      gh_curl \
        "https://api.github.com/repos/${repo}/releases/latest" \
      | jq -r '.tag_name'
    )"
    ;;
esac

printf '%s\n' "$version"
