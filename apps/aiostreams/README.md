# AIOStreams (ElfHosted build)

Upstream: **[Viren070/AIOStreams](https://github.com/Viren070/AIOStreams)** — licensed
**AGPL-3.0-only** as of v2.34.0.

This directory holds ElfHosted's modifications to that project, published so that
users of our hosted instances can obtain the corresponding source of the version
they are interacting with.

## What is here

- `Dockerfile` — the build. It clones upstream at the `VERSION` build arg and
  applies every patch below, in filename order, before building.
- `patches/*.patch` — our modifications, as unified diffs against that upstream
  tag. These are the complete set: the image contains no other changes to
  upstream's source.

## Reproducing the build

```sh
docker build --build-arg VERSION=v2.34.0 -f apps/aiostreams/Dockerfile .
```

The cloner stage runs each patch with `git apply` and `set -e`, so any patch that
fails to apply aborts the build rather than silently shipping without it.

## Configuration

The patches add settings under `builtins.*` and a small number of environment
variables. All of them default to off or empty: an unconfigured build behaves as
upstream does. Endpoints are supplied whole via configuration rather than
constructed in code, so no deployment-specific URLs appear in the source.

`SECRET_KEY` in the Dockerfile is a placeholder to let the smoke test start the
app. **It is not a usable key.** Any deployment must supply its own — it encrypts
stored configuration and the tokens embedded in install URLs.
