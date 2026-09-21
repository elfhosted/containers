#!/usr/bin/env bash
# Bree is OURS, so its version is ours: release-please cuts it in
# elfhosted/bree from conventional commits, exactly as gandalf does.
#
# This used to read FastAPI's current PyPI release, which made the image version
# a fact about a dependency rather than about the service -- eleven commits of
# our own shipped under one unchanged 0.141.1. It did have one merit: a FastAPI
# release rebuilt the image, so dependency fixes shipped without anybody
# deciding to. Renovate on elfhosted/bree replaces that on purpose; see the
# comment in that repo's requirements.txt.
#
# The repo is private, hence the token -- the same one the Dockerfile clones with.
version=$(curl -L -sX GET https://api.github.com/repos/elfhosted/bree/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
printf "%s" "${version}"
