ARG VERSION
# Get the source
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://gitlab.com/storyteller-platform/storyteller-base.git /source-storyteller-base
RUN git clone -b web-$VERSION https://gitlab.com/storyteller-platform/storyteller.git /source

# # Build the base
# FROM ghcr.io/elfhosted/ubuntu-jammy:rolling@sha256:f9f982e780fbad497108c83fdbc87f6a2451fff441e3687e27627b1459b527ab as base

# RUN apt-get update && \
#   DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
#   build-essential \
#   git \
#   cmake \
#   software-properties-common \
#   sqlite3 \
#   libsqlite3-dev \
#   argon2 \
#   wget \
#   ca-certificates \
#   curl \
#   gnupg \
#   libelf1 \
#   libnuma-dev \
#   kmod \
#   file \
#   python3 \
#   python3-pip \
#   tini && \
#   apt-get clean

# COPY --from=cloner /source-storyteller-base/scripts/install-node.sh .

# ARG TARGETARCH
# # Manually install node 22 from prebuilt binary
# RUN ./install-node.sh

# COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffmpeg /usr/local/bin/
# COPY --link --from=mwader/static-ffmpeg:6.1.1 /ffprobe /usr/local/bin/

# FROM base AS builder
FROM registry.gitlab.com/storyteller-platform/storyteller-base:latest AS builder

WORKDIR /app

# Download word list
RUN wget https://raw.githubusercontent.com/dwyl/english-words/master/words.txt

COPY --from=cloner /source/package.json /source/yarn.lock /source/.yarnrc.yml ./
COPY --from=cloner /source/.yarn/releases ./.yarn/releases
COPY --from=cloner /source/.yarn/cache ./.yarn/cache

COPY --from=cloner /source/web/package.json ./web/package.json
COPY --from=cloner /source/fs/package.json ./fs/package.json
COPY --from=cloner /source/epub/package.json ./epub/package.json
COPY --from=cloner /source/path/package.json ./path/package.json
COPY --from=cloner /source/audiobook/package.json ./audiobook/package.json
COPY --from=cloner /source/config/tsup/package.json ./config/tsup/package.json

RUN yarn install

COPY --from=cloner /source/docker-scripts/ ./scripts/

COPY --from=cloner /source/. .

RUN cp docker-scripts/* ./scripts/

RUN gcc -g -fPIC -rdynamic -shared web/sqlite/uuid.c -o web/sqlite/uuid.c.so

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ARG CI_COMMIT_TAG
ENV CI_COMMIT_TAG=${CI_COMMIT_TAG}

ENV SQLITE_NATIVE_BINDING=/app/node_modules/better-sqlite3/build/Release/better_sqlite3.node

RUN yarn workspaces foreach -Rpt --from @storyteller-platform/web run build

FROM registry.gitlab.com/storyteller-platform/storyteller-base:latest AS runner

WORKDIR /app

COPY --from=builder /app/web/.next/standalone ./.next/standalone
COPY --from=builder /app/web/public ./.next/standalone/web/public
COPY --from=builder /app/web/.next/static ./.next/standalone/web/.next/static
COPY --from=builder /app/web/sqlite/uuid.c.so ./.next/standalone/web/sqlite/uuid.c.so

# Copy SQL migrations
COPY --from=builder /app/web/migrations ./.next/standalone/web/migrations

# WASM files aren't statically imported, so esbuild doesn't find them and they need to be manually copied over
COPY --from=builder /app/node_modules/@echogarden/speex-resampler-wasm/wasm/*.wasm ./.next/standalone/web/work-dist/
COPY --from=builder /app/node_modules/@echogarden/pffft-wasm/dist/simd/pffft.wasm ./.next/standalone/web/work-dist/
COPY --from=builder /app/node_modules/tiktoken/lite/tiktoken_bg.wasm ./.next/standalone/web/work-dist/

# Unfortunately, echogarden attempts to manually resolve some of its own files
COPY --from=builder /app/node_modules/echogarden/data ./.next/standalone/data
COPY --from=builder /app/node_modules/echogarden/dist ./.next/standalone/dist
COPY --from=builder /app/node_modules/@echogarden/espeak-ng-emscripten/espeak-ng.data ./.next/standalone/web/work-dist/

EXPOSE 8001

ARG VERSION
ENV CI_COMMIT_TAG=web-${VERSION}

ENV PORT=8001
ENV HOSTNAME=0.0.0.0
ENV STORYTELLER_DATA_DIR=/data
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV SQLITE_NATIVE_BINDING=/app/.next/standalone/node_modules/better-sqlite3/build/Release/better_sqlite3.node
ENV STORYTELLER_WORKER=worker.cjs
ENV STORYTELLER_FILE_WRITE_WORKER=fileWriteWorker.cjs

WORKDIR /app/.next/standalone/web

COPY --from=builder /app/words.txt ./words.txt

ENTRYPOINT ["/usr/bin/tini", "--"]


ARG user=elfie
RUN groupadd -g 568 $user && useradd --create-home --uid 568 --gid 568 --shell /bin/bash $user

CMD ["node", "--enable-source-maps", "server.js"]
