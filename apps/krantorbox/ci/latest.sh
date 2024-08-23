#!/usr/bin/env bash

version=$(git ls-remote https://gitlab.com/book2566/krantorbox.git HEAD | awk '{ print $1}')
printf "%s" "${version}"