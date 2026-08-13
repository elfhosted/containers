#!/usr/bin/env bash
# Foundry Virtual Tabletop is proprietary software distributed by Foundry Gaming LLC.
# It is NOT published on GitHub and there is no public releases API to poll, so this
# cannot auto-detect upstream versions the way every other app here does.
#
# The image we build does not contain Foundry itself. It is a launcher: Foundry is
# downloaded at container start using the tenant's own licence key / timed download
# URL (see the Dockerfile). The version below therefore tracks OUR launcher, not
# Foundry, and is bumped by hand when the launcher changes.
#
# The Foundry version a tenant actually runs is whatever their timed download URL
# points at, which is decided on foundryvtt.com, not here. There is no version
# selector in this image.
printf "%s" "1.0.0"
