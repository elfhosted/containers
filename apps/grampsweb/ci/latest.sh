#!/usr/bin/env bash
# We overlay ElfHosted conventions onto the upstream combined image
# ghcr.io/gramps-project/grampsweb, which is tagged with the gramps-web
# (frontend) CalVer release WITHOUT a "v" prefix (e.g. 26.6.2). The bundled
# gramps-web-api backend version rides along with each frontend release, so we
# track gramps-web releases to stay in lockstep with the published image tag.
version=$(curl -sX GET "https://api.github.com/repos/gramps-project/gramps-web/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
