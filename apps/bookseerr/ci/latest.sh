#!/usr/bin/env bash
# BookSeerr is hosted on a self-hosted GitLab instance with no releases or tags,
# so we track the short commit SHA of the main branch. Project id 53 is stable
# (resolved from /api/v4/projects/marco%2Fbookseerr). The GitLab API is public
# and needs no auth for read access.
version=$(curl -sX GET "https://gitlab.bertorello.info/api/v4/projects/53/repository/commits/main" | jq --raw-output '.short_id')
printf "%s" "${version}"
