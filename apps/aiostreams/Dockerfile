# Get upstream code - we use node in this case
# we need node in this case for the metadata script
FROM node:26-alpine as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/Viren070/AIOStreams.git /source

# Apply our patches
COPY apps/aiostreams/patches/ /patches/

# Fail the build on any failed patch. Without `set -e` the loop swallows
# `git apply` failures and the image silently ships without some patches.
RUN set -e; cd /source; pn=0; for p in /patches/*.patch; do pn=$((pn+1)); echo "Applying patch $pn"; git apply "$p"; done

WORKDIR /source

# Update metadata
RUN mkdir /resources && \
    npm run metadata

FROM node:26.13.0-slim AS base

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
COPY --from=cloner /source/packages/ui/package*.json ./packages/ui/
COPY --from=cloner /source/packages/web/package*.json ./packages/web/
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
COPY --from=cloner /source/packages/ui ./packages/ui
COPY --from=cloner /source/packages/web ./packages/web
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
RUN rm -rf packages/ui/node_modules
RUN rm -rf packages/web/node_modules
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
# v2.35.0 added the Jellyfin web app; v2.36.0 renamed its workspace from
# packages/jellyfin-web to packages/web. The server serves packages/web/dist.
COPY --from=builder /build/packages/web/dist ./packages/web/dist
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

# v2.36.0 probes a file's tracks with ffprobe on first play (FFPROBE_PATH
# defaults to `ffprobe` on the PATH). Mirrors upstream's Dockerfile: a minimal
# static ffprobe, since the distroless runtime has no package manager.
# zlib is linked statically: the runtime image has no libz.
FROM debian:12-slim AS ffprobe
ARG FFMPEG_VERSION=8.1.3
ARG FFMPEG_SHA256=7138d28c96d9d3e3af4ee3d8cad72741f8ffb40da90c1112235dea3ecd3178a3
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl xz-utils gcc libc6-dev make zlib1g-dev \
  && rm -rf /var/lib/apt/lists/* \
  && rm /usr/lib/*/libz.so
WORKDIR /src
RUN curl -fsSL -o ffmpeg.tar.xz "https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz" \
  && echo "${FFMPEG_SHA256}  ffmpeg.tar.xz" | sha256sum -c - \
  && tar -xJf ffmpeg.tar.xz --strip-components=1 \
  && ./configure \
    --disable-everything --disable-autodetect --disable-doc --disable-debug \
    --disable-programs --enable-ffprobe \
    --disable-avdevice --disable-avfilter --disable-swscale --disable-swresample \
    --disable-x86asm --enable-zlib \
    --enable-protocol=file,http,tcp \
    --enable-demuxer=asf,avi,flv,matroska,mov,mpegps,mpegts,ogg \
    --enable-parser=aac,aac_latm,ac3,av1,dca,dvbsub,dvdsub,flac,h264,hevc,mlp,mpeg4video,mpegaudio,mpegvideo,opus,vc1,vorbis,vp8,vp9 \
    --enable-decoder=aac,aac_latm,ac3,alac,dca,eac3,flac,mlp,mp2,mp3,opus,truehd,vorbis,pcm_bluray,pcm_dvd,pcm_s16le,pcm_s24le,h264,hevc,mpeg2video,mpeg4,vc1,vp8,vp9,ass,ssa,subrip,srt,webvtt,movtext,pgssub,dvdsub,dvbsub \
  && make -j"$(nproc)" ffprobe \
  && strip ffprobe

FROM gcr.io/distroless/nodejs24-debian12 AS production

LABEL org.opencontainers.image.title="AIOStreams"
LABEL org.opencontainers.image.source="https://github.com/Viren070/AIOStreams"
LABEL org.opencontainers.image.description="AIOStreams consolidates multiple Stremio addons and debrid services - including its own suite of built-in addons - into a single, highly customisable super-addon."
LABEL org.opencontainers.image.licenses="AGPL-3.0-only"

WORKDIR /app

COPY --from=busybox:1.36.0-uclibc /bin/wget /bin/wget
COPY --from=busybox:1.36.0-uclibc /bin/sh /bin/sh
# mimalloc replaces glibc's allocator: the native usenet engine churns large
# yEnc decode buffers at high throughput, which fragments the default malloc and
# balloons RSS. LD_PRELOAD keeps memory bounded without touching app code.
COPY --from=mimalloc /usr/local/lib/libmimalloc.so.2 /usr/local/lib/libmimalloc.so.2
ENV LD_PRELOAD=/usr/local/lib/libmimalloc.so.2
COPY --from=ffprobe /src/ffprobe /usr/local/bin/ffprobe
ENV NODE_OPTIONS="--max-semi-space-size=8 --expose-gc"
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
