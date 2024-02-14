#!/usr/bin/env bash

version=$(git ls-remote https://gitlab.com/stremio-add-ons/annatar.git HEAD | awk '{ print $1}')
printf "%s" "${version}"