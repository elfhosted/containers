#!/usr/bin/env bash
# releases/latest skips drafts and prereleases. Vikunja's "unstable" builds are
# Docker tags only, never GitHub releases, so this always resolves the newest
# stable vX.Y.Z. Refuse anything that is not plain semver.
version=$(curl -sX GET "https://api.github.com/repos/go-vikunja/vikunja/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    exit 1
fi
printf "%s" "${version}"
