#!/usr/bin/env bash
# version=$(curl -sX GET "https://pkgs.alpinelinux.org/packages?name=qbittorrent-nox&branch=v3.16&arch" | grep -oP '(?<=<td class="version">)[^<]*')
version=$(curl -sX GET "https://repology.org/api/v1/projects/?search=qbittorrent&inrepo=alpine_edge" -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" | jq -r '.qbittorrent | .[] | select((.repo == "alpine_edge" and .binname == "qbittorrent-nox")) | .version')
version="${version%%_*}"
version="${version%%-*}"
printf "%s" "${version}"
