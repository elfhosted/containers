#!/usr/bin/env bash
# Tracks text-embeddings-inference releases. The image we publish is that
# runtime with an embedding model baked in, so its version is upstream's.
#
# NOTE for whoever bumps this: the model is pinned by commit in the Dockerfile,
# NOT by this version. Changing the MODEL is a separate, heavier decision than
# bumping the runtime, because every vector already stored was produced by the
# old one and stays comparable only to its own kind. A model change means a
# reindex for every consumer, so it does not ride along with a routine bump.
version=$(curl -sX GET "https://api.github.com/repos/huggingface/text-embeddings-inference/releases/latest" --header "Authorization: Bearer ${TOKEN}" | jq --raw-output '.tag_name')
version="${version#*v}"
printf "%s" "${version}"
