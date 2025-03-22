#!/usr/bin/env bash
version=$(curl -s "https://hub.docker.com/v2/repositories/jvmilazz0/kavita/tags?page_size=100" | 
          jq -r '.results[] | select(.name | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) | .name' | 
          head -n 1)
printf "%s" "${version}"