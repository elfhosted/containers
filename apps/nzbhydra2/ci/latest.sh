#!/usr/bin/env bash

# proxy.patch (containers-private) does not apply to upstream 9.3.2 or later:
# IndexerWebAccess, WebAccess and HydraOkHttp3ClientHttpRequestFactory were
# refactored, and every build of both channels failed at the patch step. Until
# the patch is rebased, build 9.3.1, the release production's nzbhydra2-proxy
# image is built from. Restore the lookup below when removing this pin.
printf "%s" "9.3.1"
exit 0

version=$(curl -L -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.[0].tag_name')
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
