#!/usr/bin/env bash
# Track the newest Emby beta (prerelease) that actually ships the Debian package
# the Dockerfile downloads. Emby sometimes publishes a prerelease before (or
# without) uploading its emby-server-deb_<v>_amd64.deb asset — e.g. 4.11.0.9 —
# which 404s the build's curl. Skip those and fall back to the newest beta that
# carries the .deb (e.g. 4.11.0.8).
version=$(curl -L -sX GET https://api.github.com/repos/MediaBrowser/Emby.Releases/releases --header "Authorization: Bearer ${TOKEN}" | jq -r 'first(.[] | select(.prerelease == true) | select(any(.assets[]?; .name | test("^emby-server-deb_.*_amd64\\.deb$"))) | .tag_name)')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
