#!/usr/bin/env bash
# In-house image: the OpenAI-compatible chat gateway tenant apps are pointed at.
# It is a FastAPI app, and the Dockerfile installs FastAPI at exactly this
# version, so a new FastAPI release rebuilds the image. Same arrangement as
# smtp-relay, which anchors on aiosmtpd.
#
# The gateway's own code lives in containers-private and changes with its own
# commits, which trigger a build directly -- this only governs the version
# LABEL and the dependency floor.
version=$(curl -sL "https://pypi.org/pypi/fastapi/json" | jq --raw-output '.info.version')
printf "%s" "${version}"
