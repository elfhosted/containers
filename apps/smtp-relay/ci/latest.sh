#!/usr/bin/env bash
# In-house image: a localhost-only mail relay built on msmtp from the Alpine
# repository our base image (ghcr.io/elfhosted/alpine:rolling, currently 3.19)
# installs from, so a new msmtp package rebuilds the image. Update the branch
# here if the base image moves to a newer Alpine.
version=$(curl -sL "https://dl-cdn.alpinelinux.org/alpine/v3.19/community/x86_64/APKINDEX.tar.gz" \
  | tar -xzO APKINDEX 2>/dev/null \
  | awk '/^P:msmtp$/{f=1} f&&/^V:/{sub("V:","");print;exit}')
printf "%s" "${version}"
