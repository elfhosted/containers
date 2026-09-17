#!/usr/bin/env bash
# One image ships two upstream projects: the Shlink server and its web client.
# The version is "<shlink>-<web-client>" (e.g. 5.1.6-4.8.1) so a release of
# either one triggers a rebuild; the Dockerfile splits it back apart.
shlink=$(curl -L -sX GET "https://api.github.com/repos/shlinkio/shlink/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
webclient=$(curl -L -sX GET "https://api.github.com/repos/shlinkio/shlink-web-client/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
printf "%s" "${shlink#v}-${webclient#v}"
