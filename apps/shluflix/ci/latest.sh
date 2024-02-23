#!/usr/bin/env bash
version=$(git ls-remote https://bitbucket.org/shluflix-stremio/shluflix.git HEAD | awk '{ print $1}')
printf "%s" "${version}"