#!/usr/bin/env bash
# ArchiveBox tags releases as vX.Y.Z; 0.8.x/0.9.x are marked prerelease, so
# /releases/latest correctly returns the newest stable (0.7.x as of 2026-07)
version=$(curl -sX GET "https://api.github.com/repos/ArchiveBox/ArchiveBox/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
