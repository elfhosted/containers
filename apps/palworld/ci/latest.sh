#!/usr/bin/env bash
# VERSION here is the thijsvanloef/palworld-server-docker image release (e.g.
# 2.7.2, published to Docker Hub as v2.7.2 -- the Dockerfile re-adds the v).
# It is NOT the Palworld version: the game server is downloaded from Steam at
# boot, and whatever Steam serves is the only version current clients can join,
# so there is nothing to pin. See the Dockerfile for why that distinction is
# load-bearing rather than incidental.
version=$(curl -fsSL -X GET "https://api.github.com/repos/thijsvanloef/palworld-server-docker/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
