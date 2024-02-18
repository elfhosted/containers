version=$(curl -sX GET "https://api.github.com/repos/aymene69/stremio-jackett-cacher/commits/main" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.sha')
printf "%s" "${version}"
