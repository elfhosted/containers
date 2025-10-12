#!/usr/bin/env bash

channel=$1
if [[ "${channel}" == "dev" ]]; then
    version=$(curl -sX GET "https://api.github.com/repos/cedya77/aiometadata/tags" --header "Authorization: Bearer ${TOKEN}" jq -r '.[].name | select(test("beta"))' | head -n 1)
else
    version=$(curl -sX GET https://api.github.com/repos/cedya77/aiometadata/tags --header "Authorization: Bearer ${TOKEN}" | jq -r '.[].name | select((test("beta") | not) and (test("^v5") | not))' | head -n 1)
fi
printf "%s" "${version}"   