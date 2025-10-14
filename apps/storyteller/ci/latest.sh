#!/usr/bin/env bash
version="$(
  curl -s "https://gitlab.com/api/v4/projects/storyteller-platform%2Fstoryteller/repository/tags" \
  | jq -r '.[].name' \
  | grep '^web-' \
  | sed -E 's/^web-//' \
  | sed -E 's/^v//' \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
  | sort -V \
  | tail -n 1
)"
printf "%s" "${version}"
