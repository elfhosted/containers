#!/usr/bin/env bash

APP="${1}"
CHANNEL="${2}"
export TOKEN="${TOKEN}"
export ZURG_GH_CREDS="${ZURG_GH_CREDS}"

if test -f "./apps/${APP}/ci/latest.sh"; then
    bash ./apps/"${APP}"/ci/latest.sh "${CHANNEL}"
fi
