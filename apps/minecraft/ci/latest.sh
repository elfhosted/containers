#!/usr/bin/env bash
# VERSION here is the itzg/docker-minecraft-server image release (CalVer, e.g.
# 2026.8.0), NOT the Minecraft version. The Minecraft version and the server
# flavour (Paper/Fabric/Forge) are runtime settings, because the server jar is
# downloaded and assembled at boot rather than baked into the image. See the
# Dockerfile for why that distinction is load-bearing rather than incidental.
version=$(curl -fsSL -X GET "https://api.github.com/repos/itzg/docker-minecraft-server/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
