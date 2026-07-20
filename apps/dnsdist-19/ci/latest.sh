#!/usr/bin/env bash
# Highest 1.9.x tag of the upstream dnsdist 1.9 line. Re-hosted as
# ghcr.io/elfhosted/dnsdist-19 (our registry, GHCR-scanned, no Docker Hub pull
# limits) — the rate-limiting/anti-abuse frontend for the direct-dns PowerDNS.
version=$(curl -s "https://hub.docker.com/v2/repositories/powerdns/dnsdist-19/tags?page_size=100" \
  | jq --raw-output '.results[].name' \
  | grep -E '^1\.9\.[0-9]+$' \
  | sort -V \
  | tail -n1)
printf "%s" "${version}"
