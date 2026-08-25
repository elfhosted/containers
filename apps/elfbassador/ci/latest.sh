#!/usr/bin/env bash
# elfbassador tags releases as vX.Y.Z, but its images have always been tagged
# WITHOUT the v (ghcr.io/elfhosted/elfbassador:1.5.1, which is what
# infra/elfbassador/helmrelease-elfbassador.yaml pins). Strip it here so the
# series continues unbroken — switching to v-prefixed tags mid-stream risks
# renovate not offering the bump at all, which fails silently.
# The Dockerfile puts the v back to clone the tag.
version=$(curl -sX GET https://api.github.com/repos/elfhosted/elfbassador/releases/latest --header "Authorization: Bearer ${ZURG_GH_CREDS}" | jq --raw-output '. | .tag_name')
printf "%s" "${version#v}"
