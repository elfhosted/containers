#!/usr/bin/env bash
# Posteria has no GitHub releases or tags; version is tracked in a `version` file on main.
version=$(curl -s "https://raw.githubusercontent.com/jeremehancock/Posteria/main/version")
printf "%s" "${version}"
