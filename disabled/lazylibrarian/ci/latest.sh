#!/usr/bin/env bash
version="$(curl -sX GET "https://gitlab.com/api/v4/projects/9317860/repository/commits/master" | awk '/id/{print $4;exit}' FS='[""]')"
version="${version#*v}"
version="${version#*release-}"
printf "%s" "${version}"
