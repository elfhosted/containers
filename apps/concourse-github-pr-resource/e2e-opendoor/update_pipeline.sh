#!/usr/bin/env bash
set -euo pipefail

fly -t od set-pipeline \
    --pipeline "sample-opendoor-github-pr-resource" \
    --config "pipeline.yaml" -n
