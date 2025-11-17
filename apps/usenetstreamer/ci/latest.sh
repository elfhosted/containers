#!/usr/bin/env bash
version=$(curl -sL --header "Authorization: Bearer ${TOKEN}" "https://ghcr.io/v2/sanket9225/usenetstreamer/tags/list" | 
          jq -r '.tags[]' | 
          grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | 
          sort -V | 
          tail -n 1)
printf "%s" "${version}"