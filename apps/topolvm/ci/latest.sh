#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/topolvm/topolvm/releases | jq -r '.[].tag_name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n1)
version="${version#*v}"
printf "%s" "${version}"