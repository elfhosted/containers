#!/usr/bin/env bash
version=$(curl -s "https://hub.docker.com/v2/repositories/jvmilazz0/kavita/tags?page_size=100" | jq -r '.results[0].name')
printf "%s" "${version}"