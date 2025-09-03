#!/usr/bin/env bash
set -euo pipefail

# Prints the version of the latest Plex Pass (beta/early-access) Linux build.
# Requires: curl, jq, and PLEX_TOKEN exported in the environment.

: "${PLEX_TOKEN:?PLEX_TOKEN must be set (Plex Pass account token)}"

API_URL="https://plex.tv/api/downloads/5.json?channel=plexpass&X-Plex-Token=${PLEX_TOKEN}"

# Fetch JSON and extract the Linux version for the Plex Pass channel.
# This value reflects the newest Linux PMS for that channel.
json="$(curl -fsSL "$API_URL")"
version="$(jq -r '.computer.Linux.version // empty' <<<"$json")"

if [[ -z "$version" || "$version" == "null" ]]; then
  echo "Could not determine latest Plex Pass Linux version (check PLEX_TOKEN and subscription)" >&2
  exit 1
fi

# Normalize: strip leading "v" or "release-" if present (matches your old script behavior)
version="${version#v}"
version="${version#release-}"

printf "%s" "$version"
