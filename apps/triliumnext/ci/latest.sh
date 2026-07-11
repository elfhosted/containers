#!/usr/bin/env bash
# Tags in TriliumNext/Trilium include non-app releases (e.g. web-clipper-v1.1.1),
# so filter /releases for vX.Y.Z tags rather than trusting /releases/latest blindly.
version=$(curl -sX GET "https://api.github.com/repos/TriliumNext/Trilium/releases" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '[.[] | select(.prerelease == false and .draft == false) | .tag_name | select(test("^v[0-9]"))] | first')
version="${version#*v}"
printf "%s" "${version}"
