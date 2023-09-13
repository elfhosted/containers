#!/usr/bin/env bash

version=$(git -c 'versionsort.suffix=-' ls-remote --exit-code --refs --sort='version:refname' --tags https://github.com/laurent22/joplin.git 'server-*.*.*' | tail --lines=1 | cut -d\- -f2)
printf "%s" "${version}"
