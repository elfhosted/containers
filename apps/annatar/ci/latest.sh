#!/usr/bin/env bash
version=$(curl -SLs https://gitlab.com/api/v4/projects/54800933/releases | jq -r '.[0].tag_name')
version="${version#*v}"
printf "%s" "${version}"