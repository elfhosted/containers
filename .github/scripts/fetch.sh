#!/usr/bin/env bash
# FIXME: Consider rewriting this in Python3

# Overview:
# Builds a JSON string what images and their channels to process
# Outputs:
# [
#    {"app":"ubuntu", "channel": "focal"},
#    {"app":"ubuntu", "channel": "jammy"},
#    {"app"...
# ]

trap 'exit 130' INT

declare -a latest_records=()
declare -a changes_array=()
while read -r metadata; do
    app="$(jq --raw-output '.app' "${metadata}")"
    while read -r channels; do
        channel="$(jq --raw-output '.name' <<< "${channels}")"
        stable="$(jq --raw-output '.stable' <<< "${channels}")"
        published_version=$(./.github/scripts/published.sh "${app}" "${channel}" "${stable}")
        upstream_version=$(./.github/scripts/upstream.sh "${app}" "${channel}" "${stable}")

        latest_records+=("$(jo app="${app}" channel="${channel}" stable="${stable}" publishedVersion="${published_version}")")
        if [[ "${published_version}" != "${upstream_version}" ]]; then
            echo "${app}$([[ ! ${stable} == false ]] || echo "-${channel}"):${published_version:-<NOTFOUND>} -> ${upstream_version}"
            changes_array+=("$(jo app="${app}" channel="${channel}")")
        fi
    done < <(jq --raw-output -c '.channels | .[]' "${metadata}")
done < <(find ./apps -name metadata.json)

output="[]"
if [[ "${#changes_array[@]}" -gt 0 ]]; then
    #shellcheck disable=SC2048,SC2086
    output="$(jo -a ${changes_array[*]})"
fi

echo "::set-output name=changes::${output}"

latest_output="[]"
if [[ "${#latest_records[@]}" -gt 0 ]]; then
    #shellcheck disable=SC2048,SC2086
    latest_output="$(jo -a ${latest_records[*]})"
fi

echo "::set-output name=latestVersions::${latest_output}"
