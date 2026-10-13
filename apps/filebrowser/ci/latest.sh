#!/usr/bin/env bash
set -euo pipefail
channel=${1:-main}

# gtsteffaniak/filebrowser publishes preview/beta tags as GitHub releases, and
# some preview releases are not flagged as prerelease by upstream. The stable
# channel must not follow those; only use tags that are explicitly stable-ish.
curl_args=(-fsSL "https://api.github.com/repos/gtsteffaniak/filebrowser/releases?per_page=100")
if [[ -n "${TOKEN:-}" ]]; then
    curl_args+=(--header "Authorization: Bearer ${TOKEN}")
fi
# Held on the v1 line. v2.0.0 moves the database from Bolt to SQLite and
# changes the config schema, so it needs a chart migration (with a rollback
# path) before tenants can run it; we are also letting v2 settle for a few
# point releases. Upstream still ships v1.x stable fixes, which this follows.
version=$(curl "${curl_args[@]}"   | jq --raw-output '[.[] | select(.draft == false) | select(.prerelease == false) | select(.tag_name | test("(?i)(preview|alpha|beta|rc)") | not) | select(.tag_name | startswith("v1."))][0].tag_name')

if [[ -z "${version}" || "${version}" == "null" ]]; then
    echo "Unable to resolve a stable filebrowser release" >&2
    exit 1
fi

printf "%s" "${version}"
