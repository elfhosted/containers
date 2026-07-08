#!/usr/bin/env bash
set -euo pipefail

# Hermes Agent uses date-based CalVer tags (e.g. v2026.7.7.2). The git tag is
# returned verbatim (with leading "v") because the Dockerfile clones -b $VERSION.
channel="${1:-stable}"
repo="nousresearch/hermes-agent"

gh_curl() {
  if [[ -n "${TOKEN-}" ]]; then
    curl -fsSL -H "Authorization: Bearer ${TOKEN}" "$@"
  else
    curl -fsSL "$@"
  fi
}

case "$channel" in
  dev)
    version="$(gh_curl "https://api.github.com/repos/${repo}/commits/main" | jq -r '.sha[0:7]')"
    ;;
  *)
    version="$(gh_curl "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name')"
    ;;
esac

printf '%s' "${version}"
