#!/usr/bin/env bash
# Upstream has published a release whose tag is a placeholder ("untagged-<hash>",
# v4.16.4); the release name still carries the version, so fall back to it.
version=$(curl -L -sX GET "https://api.github.com/repos/lukevella/rallly/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output 'if (.tag_name | startswith("untagged-")) then .name else .tag_name end')
version="${version#*v}"
printf "%s" "${version}"
