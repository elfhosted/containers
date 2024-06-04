#!/usr/bin/env bash

APP="${1}"
CHANNEL="${2}"
STABLE="${3}"

if [[ -z "${STABLE}" || "${STABLE}" == false ]]; then
    APP="${APP}-${CHANNEL}"
fi

tags=$( \
    curl -fsSL \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer ${TOKEN}" \
        "https://api.github.com/orgs/elfhosted/packages/container/${APP}/versions" \
        2>/dev/null
)

if [[ -z "${tags}" ]]; then
    exit 0
fi

current_tags=$( \
    jq --compact-output \
        'map( select( .metadata.container.tags[] | contains("rolling") ) | .metadata.container.tags[] )' \
            <<< "${tags}" \
)

tag=$( \
    jq --compact-output \
        'map( select( index("rolling") | not ) )' \
            <<< "${current_tags}"
)

printf "%s" "$(jq --raw-output '.[0]' <<< "${tag}")"
