#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/scripts/vpn.sh"

#shellcheck disable=SC2086

# We run from /tmp so that we can create a temporary folder for this, and leave /app as read-only
cd /tmp
cp /app/appsettings.json ./

exec \
    dotnet /app/RdtClient.Web.dll