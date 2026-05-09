#!/usr/bin/env bash
channel=$1

if [ "$channel" == "main" ]; then
    # For main channel, get the latest stable release.
    # Upstream sometimes flags pre-release tags (beta/alpha/rc/pre) as `prerelease=false`,
    # so /releases/latest can't be trusted — filter by tag pattern instead.
    version=$(curl -sX GET "https://api.github.com/repos/mhdzumair/MediaFusion/releases?per_page=100" \
        --header "Authorization: Bearer ${TOKEN}" | \
        jq -r '[.[] | select(.draft == false) | select(.tag_name | test("beta|alpha|rc|pre"; "i") | not)] | sort_by(.created_at) | last | .tag_name')
elif [ "$channel" == "dev" ]; then
    # For dev channel, get the most recently created release (stable or pre-release)
    version=$(curl -sX GET "https://api.github.com/repos/mhdzumair/MediaFusion/releases?per_page=100" \
        --header "Authorization: Bearer ${TOKEN}" | \
        jq -r '[.[] | select(.draft == false)] | sort_by(.created_at) | last | .tag_name')
else
    echo "Invalid channel specified"
    exit 1
fi

version="${version#*v}"
printf "%s" "${version}"