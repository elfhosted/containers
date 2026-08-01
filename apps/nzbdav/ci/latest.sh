#!/usr/bin/env bash
set -euo pipefail

# Track the latest stable release from the nzbdav community fork.
# The private Dockerfile/patch stack must be kept current with this output;
# release-schedule should surface drift instead of silently staying pinned.
curl -fsSL \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/nzbdav/nzbdav/releases/latest \
  | jq -r '.tag_name'
