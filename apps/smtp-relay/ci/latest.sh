#!/usr/bin/env bash
# In-house image: a localhost-only mail relay built on aiosmtpd, which the
# Dockerfile installs at exactly this version, so a new aiosmtpd release rebuilds
# the image.
version=$(curl -sL "https://pypi.org/pypi/aiosmtpd/json" | jq --raw-output '.info.version')
printf "%s" "${version}"
