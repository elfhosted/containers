#!/usr/bin/env bash
version="$(curl -sX GET https://linux-packages.resilio.com/resilio-sync/deb/dists/resilio-sync/non-free/binary-amd64/Packages |grep -A 7 -m 1 'Package: resilio-sync' | awk -F ': ' '/Version/{print $2;exit}')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
