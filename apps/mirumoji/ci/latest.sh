#!/usr/bin/env bash
# Mirumoji tags releases as vX.Y.Z (e.g. v3.7.2); the Dockerfile re-adds the
# "v" when cloning, so only the bare version is emitted here.
version=$(curl -sX GET "https://api.github.com/repos/svdC1/mirumoji/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
