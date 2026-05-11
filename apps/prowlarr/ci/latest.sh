#!/usr/bin/env bash
set -euo pipefail

# The "channel" arg is informational only here. The container builds from
# elfhosted/prowlarr@elfhosted regardless of channel; this script only
# resolves a VERSION string to bake into AssemblyVersion/package_info.
# Matching the radarr pattern: always query upstream's stable (master)
# channel. Previously this script substituted ${channel} into the URL
# directly, which returned "null" for any channel name that didn't exist
# on prowlarr.servarr.com (e.g. our internal "main" channel) — that
# null then propagated to the Docker build and broke dotnet's NuGet
# restore with "'null' is not a valid version string".
channel=${1:-}

version=$(curl -sX GET "https://prowlarr.servarr.com/v1/update/master/changes?os=linux&runtime=netcore" | jq --raw-output '.[0].version' 2>/dev/null)

if [[ -z "$version" || "$version" == "null" ]]; then
    echo "ERROR: prowlarr latest.sh got empty/null version from prowlarr.servarr.com (channel arg was '${channel}')" >&2
    exit 1
fi

version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
