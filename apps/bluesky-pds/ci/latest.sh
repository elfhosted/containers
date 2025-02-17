#!/usr/bin/env bash
version=$(curl -s "https://api.github.com/repos/bluesky-social/pds/tags" --header "Authorization: Bearer ${TOKEN}"  | jq -r '[.[] | .name | select(test("^v?[0-9]+(\\.[0-9]+)*(\\.[0-9]+)*$"))] | sort_by(sub("^v"; "") | split(".") | map(try tonumber catch 0)) | reverse[0]')
printf "%s" "${version}"
