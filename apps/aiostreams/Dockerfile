# Get upstream code - we use node in this case
# we need node in this case for the metadata script
FROM node:22-alpine as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/Viren070/AIOStreams.git /source

# Apply our patches
COPY apps/aiostreams/patches/ /patches/

# Fail the build on any failed patch. Without `set -e` the loop swallows
# `git apply` failures and we silently ship an image missing features
# (cost us an "undefined variable: keyword" prod incident — see
# https://github.com/Viren070/AIOStreams keyword() commit on v2.29.6+).
RUN set -e; cd /source; for p in /patches/*.patch; do echo "Applying $p..."; git apply "$p"; done

WORKDIR /source

# Update metadata
RUN mkdir /resources && \
    npm run metadata

FROM node:24.18.1-slim AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS builder

WORKDIR /build

# Build toolchain for native addons that lack prebuilt binaries on this platform
# (e.g. yencode, used by the native usenet engine, has no linux/arm64 prebuild and
# must be compiled with node-gyp → needs Python + a C/C++ toolchain). These tools
# live only in the builder/runtime stages; the final distroless image just copies
# the already-compiled .node binaries, so it stays clean.
RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 make g++ \
  && rm -rf /var/lib/apt/lists/*

# Copy LICENSE file.
COPY --from=cloner /source/LICENSE ./

# Copy the relevant package.json and package-lock.json files.
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/packages/server/package*.json ./packages/server/
COPY --from=cloner /source/packages/core/package*.json ./packages/core/
COPY --from=cloner /source/packages/frontend/package*.json ./packages/frontend/
COPY --from=cloner /source/packages/seanime-extensions/package*.json ./packages/seanime-extensions/
COPY --from=cloner /source/packages/crypto/package*.json ./packages/crypto/
COPY --from=cloner /source/pnpm-workspace.yaml ./pnpm-workspace.yaml
COPY --from=cloner /source/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=cloner /source/patches ./patches

# Install dependencies.
RUN pnpm install --frozen-lockfile

# Copy source files.
COPY --from=cloner /source/tsconfig.*json ./

COPY --from=cloner /source/packages/server ./packages/server
COPY --from=cloner /source/packages/core ./packages/core
COPY --from=cloner /source/packages/frontend ./packages/frontend
COPY --from=cloner /source/packages/seanime-extensions ./packages/seanime-extensions
COPY --from=cloner /source/packages/crypto ./packages/crypto
COPY --from=cloner /source/scripts ./scripts
COPY --from=cloner /source/resources ./resources


# Build the project.
RUN pnpm run build

# Remove development dependencies.
RUN rm -rf node_modules
RUN rm -rf packages/core/node_modules
RUN rm -rf packages/server/node_modules
RUN rm -rf packages/frontend/node_modules
RUN rm -rf packages/seanime-extensions/node_modules

RUN pnpm install --prod --frozen-lockfile


FROM builder AS runtime
WORKDIR /runtime

# Copy the built files from the builder.
# The package.json files must be copied as well for NPM workspace symlinks between local packages to work.
COPY --from=builder /build/package*.json /build/LICENSE ./
COPY --from=builder /build/pnpm-workspace.yaml ./pnpm-workspace.yaml
COPY --from=builder /build/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /build/patches ./patches

COPY --from=builder /build/packages/core/package.*json ./packages/core/
COPY --from=builder /build/packages/server/package.*json ./packages/server/

# Loader + built binary; core's node_modules symlink into packages/ resolves it.
# New workspace in upstream v2.34.0 — without it the runtime cannot start.
COPY --from=builder /build/packages/crypto ./packages/crypto

COPY --from=builder /build/packages/core/dist ./packages/core/dist
# v2.30 switched frontend bundler from Next.js to rsbuild — output is
# packages/frontend/dist/ (not /out/ from the Next.js days).
COPY --from=builder /build/packages/frontend/dist ./packages/frontend/dist
COPY --from=builder /build/packages/server/dist ./packages/server/dist
COPY --from=builder /build/packages/server/src/static ./packages/server/dist/static
COPY --from=builder /build/packages/seanime-extensions/dist ./packages/seanime-extensions/dist

COPY --from=builder /build/resources ./resources
COPY --from=builder /build/scripts ./scripts

COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/packages/core/node_modules ./packages/core/node_modules
COPY --from=builder /build/packages/server/node_modules ./packages/server/node_modules

FROM debian:12-slim AS mimalloc
RUN apt-get update \
  && apt-get install -y --no-install-recommends libmimalloc2.0 \
  && rm -rf /var/lib/apt/lists/* \
  && cp /usr/lib/*/libmimalloc.so.2 /usr/local/lib/libmimalloc.so.2

FROM gcr.io/distroless/nodejs24-debian12 AS production

LABEL org.opencontainers.image.title="AIOStreams"
LABEL org.opencontainers.image.source="https://github.com/Viren070/AIOStreams"
LABEL org.opencontainers.image.description="AIOStreams consolidates multiple Stremio addons and debrid services - including its own suite of built-in addons - into a single, highly customisable super-addon."
LABEL org.opencontainers.image.licenses="AGPL-3.0-only"

WORKDIR /app

COPY --from=busybox:1.38.0-uclibc /bin/wget /bin/wget
COPY --from=busybox:1.38.0-uclibc /bin/sh /bin/sh
# mimalloc replaces glibc's allocator: the native usenet engine churns large
# yEnc decode buffers at high throughput, which fragments the default malloc and
# balloons RSS. LD_PRELOAD keeps memory bounded without touching app code.
COPY --from=mimalloc /usr/local/lib/libmimalloc.so.2 /usr/local/lib/libmimalloc.so.2
ENV LD_PRELOAD=/usr/local/lib/libmimalloc.so.2
COPY --from=runtime /runtime /app

COPY --from=cloner /source /upstream-source

CMD ["/nodejs/bin/node", "/app/scripts/healthcheck.js"]
EXPOSE ${PORT:-3000}

# These are defaults required to goss-test, and are expected to be overridden by the user.
# Placeholder so the goss smoke test can start the app. It is NOT a usable
# key: every deployment must supply its own SECRET_KEY, and one that leaks
# exposes stored credentials and install-URL tokens.
ENV SECRET_KEY=0000000000000000000000000000000000000000000000000000000000000000 \
    BASE_URL=https://example.com
    
CMD ["/app/packages/server/dist/server.js"]
