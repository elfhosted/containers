#!/usr/bin/env bash

# Resolve the version/ref to build for the elfhosted CI pipeline.
#
# Source is the PRIVATE ElfHosted fork (elfhosted/plexio), so the GitHub API
# call must authenticate with ZURG_GH_CREDS — the same credential the Dockerfile
# uses to clone the repo. The pipeline's GITHUB_TOKEN is scoped to the public
# containers repo only; against the private repo's API it returns "null", which
# then becomes `git clone -b null ...` and fails the build (exit 128).
channel=$1
creds="${ZURG_GH_CREDS:-${TOKEN}}"
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sfX GET "https://${creds}@api.github.com/repos/elfhosted/plexio/commits/main" | jq --raw-output '.sha')
else
    version=$(curl -sfX GET "https://${creds}@api.github.com/repos/elfhosted/plexio/releases/latest" | jq --raw-output '.tag_name')
fi
printf "%s" "${version}"
