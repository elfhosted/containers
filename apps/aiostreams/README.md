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

| Variable | Effect |
|---|---|
| `INDEXER_EGRESS_PROXY` | An `http://` or `https://` forward proxy URL (optional `user:password@` and port; no path, query or fragment). When set, every Newznab API call and every NZB this process grabs itself is sent through it, in place of the forwarding endpoints, `REPLAY_BYPASS_HOSTS`, `BUILTIN_NAB_HTTP_PROXY` and `ADDON_PROXY`. Loopback, private (including names that resolve to private addresses), single-label and cluster-local destinations keep their usual route. An invalid value is logged once (without the value) and ignored. See `patches/49-indexer-egress-proxy.patch`. |

`SECRET_KEY` in the Dockerfile is a placeholder to let the smoke test start the
app. **It is not a usable key.** Any deployment must supply its own — it encrypts
stored configuration and the tokens embedded in install URLs.
