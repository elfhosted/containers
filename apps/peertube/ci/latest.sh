# #!/usr/bin/env bash
# version=$(curl -s -S "https://registry.hub.docker.com/v2/repositories/chocobozzz/peertube/tags/" | jq -r '."results"[]["name"]' | grep -vE "develop|latest" | head -1)
# printf "%s" "${version}"

#!/usr/bin/env bash
version=$(curl -sX GET https://api.github.com/repos/Chocobozzz/PeerTube/releases/latest --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '. | .tag_name')
printf "%s" "${version}"
