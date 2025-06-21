#!/usr/bin/env bash
version=$(curl -Ls https://pypi.org/pypi/pyload-ng/json | jq -r .info.version)
printf "%s" "${version}"
