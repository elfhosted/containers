#!/usr/bin/env bash
set -euo pipefail

# Hermes Agent uses date-based CalVer tags (e.g. v2026.7.7.2). The git tag is
# returned verbatim (with leading "v") because the Dockerfile clones -b $VERSION.
channel="${1:-main}"
repo="nousresearch/hermes-agent"
headers=(-H "Accept: application/vnd.github+json")
if [[ -n "${TOKEN:-${GITHUB_TOKEN:-}}" ]]; then
  headers+=(-H "Authorization: Bearer ${TOKEN:-${GITHUB_TOKEN:-}}")
fi

case "$channel" in
  dev)
    url="https://api.github.com/repos/${repo}/commits/main"
    version=$(curl -fsSL "${headers[@]}" "$url" | jq -r '.sha[0:7]')
    ;;
  *)
    url="https://api.github.com/repos/${repo}/releases/latest"
    version=$(curl -fsSL "${headers[@]}" "$url" | jq -r '.tag_name')
    ;;
esac

if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: hermes ${channel} resolved empty/null from ${url}" >&2
  exit 1
fi
printf '%s' "${version}"
