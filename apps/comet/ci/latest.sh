#!/usr/bin/env bash
set -euo pipefail

channel="${1:-stable}"
repo="g0ldyy/comet"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

get_commit_sha() {
  local ref="$1"
  local encoded_ref
  encoded_ref="$(printf '%s' "$ref" | jq -sRr @uri)"

  curl -fsSL \
    -H "$auth_header" \
    "https://api.github.com/repos/${repo}/commits?sha=${encoded_ref}" \
  | jq -r '.[0].sha'
}

case "$channel" in
  dev)
    version="$(get_commit_sha main)"
    ;;
  cometnet)
    version="$(get_commit_sha feat/cometnet)"
    ;;
  *)
    version="$(
      curl -fsSL \
        -H "$auth_header" \
        "https://api.github.com/repos/${repo}/releases/latest" \
      | jq -r '.tag_name'
    )"
    ;;
esac

printf '%s\n' "$version"
