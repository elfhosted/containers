version=$(curl -sX GET https://api.github.com/repos/aymene69/stremio-jackett-community/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
version="${version#*v}"
printf "%s" "${version}"
