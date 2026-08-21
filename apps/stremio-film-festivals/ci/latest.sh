#!/usr/bin/env bash
# damianjerry/stremio-film-festivals is public — auth via the workflow's default
# TOKEN. `// empty` returns "" rather than the string "null" if the releases API
# ever comes back without a tag, which the build harness then fails loudly on
# rather than publishing a null-tagged image.
version=$(curl -sX GET https://api.github.com/repos/damianjerry/stremio-film-festivals/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name // empty')
printf "%s" "${version}"
