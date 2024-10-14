#!/usr/bin/env bash
channel=$1

if [ "$channel" == "main" ]; then
    # For main channel, get the latest stable release
    version=$(curl -sX GET "https://api.github.com/repos/mhdzumair/MediaFusion/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
elif [ "$channel" == "develop" ]; then
    # For develop channel, get the latest release (including pre-releases)
    latest_release=$(curl -sX GET "https://api.github.com/repos/mhdzumair/MediaFusion/releases" --header "Authorization: Bearer ${TOKEN}" | jq '.[0]')
    
    # Use the tag_name of the latest release, whether it's a pre-release or stable
    version=$(echo "$latest_release" | jq --raw-output '.tag_name')
else
    echo "Invalid channel specified"
    exit 1
fi

version="${version#*v}"
printf "%s" "${version}"
