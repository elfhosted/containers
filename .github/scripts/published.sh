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
        "https://api.github.com/orgs/elfhosted/packages/container/${APP}/versions?per_page=100" \
        2>/dev/null
)

if [[ -z "${tags}" ]]; then
    exit 0
fi

# Try channel-specific tag first (e.g. ubuntu channels: noble-*, jammy-*, focal-*)
channel_tag=$( \
    jq --raw-output --arg ch "${CHANNEL}" \
        '[.[] | .metadata.container.tags[] | select(startswith($ch))] | .[0] // empty' \
            <<< "${tags}" \
)

if [[ -n "${channel_tag}" ]]; then
    printf "%s" "${channel_tag}"
    exit 0
fi

# Fall back to rolling-based lookup
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
