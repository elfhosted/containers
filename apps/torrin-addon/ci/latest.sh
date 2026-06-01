#!/usr/bin/env bash
set -euo pipefail

# torrin-addon source repo. The "main" channel tracks the latest release tag;
# "dev" tracks the tip of main.
channel="${1:-stable}"
repo="elfhosted/torrin-addon"
auth_header="Authorization: Bearer ${ZURG_GH_CREDS}"

case "$channel" in
  dev)
    version="$(
      curl -fsSL -H "$auth_header" \
        "https://api.github.com/repos/${repo}/commits/main" \
      | jq -r '.sha'
    )"
    ;;
  *)
    version="$(
      curl -fsSL -H "$auth_header" \
        "https://api.github.com/repos/${repo}/releases/latest" \
      | jq -r '.tag_name'
    )"
    ;;
esac

printf '%s\n' "${version}"
