#!/usr/bin/env bash
version=$(curl -s -S "https://registry.hub.docker.com/v2/repositories/superseriousbusiness/gotosocial/tags/" | jq -r '."results"[]["name"]' | grep -v latest | head -1)
printf "%s" "${version}"