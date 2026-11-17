# AIOMetadata (ElfHosted build)

Upstream: **[cedya77/aiometadata](https://github.com/cedya77/aiometadata)**. As of
v4.0.0 its core is licensed **AGPL-3.0-or-later**, and its v4 feature modules
(listed in upstream's `LICENSING.md`) are licensed **FSL-1.1-ALv2**. Releases up to
and including v3.9.0 are GPL-3.0.

This directory holds ElfHosted's modifications to that project, published so that
users of our hosted instances can obtain the corresponding source of the version
they are interacting with. Some patches modify FSL-1.1-ALv2 files; those changes
are published here under the same terms as the files they modify.

## What is here

- `Dockerfile`: the build. It clones upstream at the `VERSION` build arg and
  applies every patch below, in filename order, before building.
- `patches/*.patch`: our modifications, as unified diffs against that upstream
  tag. These are the complete set: the image contains no other changes to
  upstream's source.
- `ci/patch-smoke.cjs`: run during the build. It checks that each patch reached
  the compiled output, not only that it applied.
- `ci/goss.yaml`: the container smoke test.

## Reproducing the build

```sh
docker build --build-arg VERSION=v4.0.0 -f apps/aiometadata/Dockerfile .
```

The cloner stage runs each patch with `git apply` and `set -e`, so any patch that
fails to apply aborts the build rather than silently shipping without it. The
builder stage then runs upstream's environment-variable check, the frontend and
backend builds, a frontend type-check and the patch smoke test, and fails on any
of them.

The image needs the same services as upstream to start: a database
(`DATABASE_URI`) and Redis 8.0 or newer (`REDIS_URL`).

## Configuration

The patches add the environment variables below. Endpoints are supplied whole via
configuration rather than constructed in code, so no deployment-specific URLs
appear in the source. Unless a row says otherwise, an unset variable leaves
upstream's behaviour in place.

| Variable | Effect |
|---|---|
| `TMDB_API_BASE`, `TVDB_API_BASE`, `TVMAZE_API_BASE`, `TRAKT_API_BASE`, `MDBLIST_API_BASE`, `ANILIST_API_BASE`, `SIMKL_API_BASE`, `SIMKL_DATA_BASE`, `CINEMETA_API_BASE`, `CINEMETA_LIVE_API_BASE`, `KITSU_API_BASE`, `FANART_API_BASE`, `PUBLICMETADB_API_BASE`, `IMDB_SUGGESTION_BASE` | Base URL for that provider's API, for example to put a caching proxy in front of it. Each defaults to the provider's own address. `KITSU_API_BASE` is an origin only (no path). MDBList list URLs saved in configurations are sent through `MDBLIST_API_BASE` too. See `patches/11-metadata-base-urls.patch`, `26-mdblist-saved-list-base.patch` and `28-imdb-suggestion-base.patch`. |
| `TRAKT_AUTH_BASE` | Host for Trakt's OAuth calls (token exchange, refresh, revocation, device flow). Defaults to `https://auth.trakt.tv`. OAuth calls never use `TRAKT_API_BASE`, and any Trakt request that carries a user's token goes to Trakt directly. See `19-trakt-device-flow.patch` and `20-trakt-authed-calls-direct.patch`. |
| `TRAKT_AUTH_MODE` | Which Trakt connection flows the configure page offers: `oauth` (default), `device` (a code entered at trakt.tv, no redirect URI needed) or `both`. |
| `BUILT_IN_AI_BASE_URL` | An OpenAI-compatible endpoint. When set together with `BUILT_IN_GEMINI_API_KEY`, AI calls made with the instance's built-in key go to this endpoint instead of Google, directly rather than through any configured proxy. A configuration's own Gemini or OpenRouter key is unaffected. The endpoint is not asked to search the web, and the configure page shows the model as chosen by the instance. Empty by default. See `22-built-in-ai-endpoint.patch` and `24-lock-model-on-built-in-ai.patch`. |
| `BUILT_IN_AI_MODEL` | Model name sent to `BUILT_IN_AI_BASE_URL`. When empty, the model the caller asked for is sent. |
| `BUILT_IN_AI_API_KEY` | Bearer token sent to `BUILT_IN_AI_BASE_URL`. Empty by default. The built-in Gemini key is never sent there. |
| `TMDB_REQUEST_TIMEOUT_MS`, `TMDB_MAX_RETRIES`, and `*_REQUEST_TIMEOUT_MS` / `*_MAX_RETRIES` for `ANILIST`, `ANILIST_TRACKER`, `IMDB`, `JIKAN` (timeout only), `TVDB` (retries only), `TVMAZE`, `LETTERBOXD`, `MDBLIST` and `TRAKT` | Per-request timeout and attempt count for that provider. **These default to 5000 ms and 2 attempts**, shorter than upstream's values, so a slow provider fails sooner. Set them to upstream's values to restore its behaviour. See `04-tmdb-request-timeouts.patch` and `05-provider-request-timeouts.patch`. |
| `TMDB_DETAIL_TTL` | Cache TTL in seconds for TMDB movie, TV and collection detail responses. Defaults to one day, as upstream. |
| `ALLOW_UNSCOPED_CACHE_CLEAR` | **Wildcard and whole-keyspace cache clears are refused unless this is `true`**, because cache keys are not namespaced per instance and a shared Redis would lose other instances' entries. Exact-key deletes and clearing one title by its id still work. See `15-cache-clear-guards.patch`. |
| `LOG_FILE` (or `AIOMETADATA_LOG_FILE`), `LOG_FILE_MAX_BYTES`, `LOG_FILE_MAX_FILES`, `LOG_FILE_MAX_QUEUE_BYTES` | Also write log entries, redacted as for the dashboard, to this file, rotated at `LOG_FILE_MAX_BYTES` (default 10 MiB) keeping `LOG_FILE_MAX_FILES` files (default 5). Off when unset. |
| `TRUST_PROXY` | Express's `trust proxy` setting, so `req.ip` and the protocol come from the forwarding headers of a trusted reverse proxy: `true`, a hop count, or a comma-separated list of addresses, subnets or the names `loopback`, `linklocal`, `uniquelocal`. Unset or `false`: not trusted, as upstream. See `31-trust-proxy-from-env.patch`. |
| `CLIENT_IP_HEADER` | A request header holding the client's address, for example `cf-connecting-ip`. Used as `req.ip` only when the request came from a proxy `TRUST_PROXY` trusts. Unset: off. |
| `TRAKT_DIRECT_BASE` | Test use only, and ignored when `NODE_ENV=production`: replaces Trakt's own address for authenticated calls. |

Other behaviour the patches change, with no setting:

- The settings API reports a sensitive setting supplied by the environment as set,
  and does not return its value (`18-withhold-env-secrets.patch`).
- `/api/config` reports whether Trakt and Simkl are configured (`hasTrakt`,
  `hasSimkl`) instead of serving their client ids (`21-withhold-public-client-ids.patch`).
- Calls made through a configured base URL are recorded under the tracker's own
  host, so failed tracker writes are still retried (`29-tracker-calls-proxied-hosts.patch`).
- With several replicas, the one-time cache cleanup and the scheduled MovieLens
  re-sync run once per pass rather than once per replica (`09-cache-cleanup-lock.patch`,
  `30-movielens-sync-single-run.patch`).
- TMDB trending results and TVDB remote-id lookups are cached
  (`06-cache-trending-and-remoteid.patch`), and a `tv` type is treated as `series`
  (`08-normalize-tv-type.patch`).
- `99-register-env-vars.patch` registers the variables above with upstream's
  environment-variable check.
