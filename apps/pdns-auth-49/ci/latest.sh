#!/usr/bin/env bash
# Highest 4.9.x tag of the upstream PowerDNS Authoritative 4.9 LTS image.
# We re-host it (ghcr.io/elfhosted/pdns-auth-49) so the direct-dns PowerDNS
# pods pull from our own registry (Docker Hub anonymous pull limits bite on
# some DC egress IPs) and get scanned like every other image we ship.
version=$(curl -s "https://hub.docker.com/v2/repositories/powerdns/pdns-auth-49/tags?page_size=100" \
  | jq --raw-output '.results[].name' \
  | grep -E '^4\.9\.[0-9]+$' \
  | sort -V \
  | tail -n1)
printf "%s" "${version}"
