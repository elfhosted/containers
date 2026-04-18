ARG VERSION
ARG BASE_TAG=main
ARG WHISPER_VARIANT=""
ARG READIUM_VERSION=0.6.5

FROM ghcr.io/readium/readium:${READIUM_VERSION} AS readium

# Get the source
FROM alpine:latest AS cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git git-lfs

RUN git lfs install --system --skip-repo && \
    git clone -b web-v$VERSION https://gitlab.com/storyteller-platform/storyteller.git /source

FROM registry.gitlab.com/storyteller-platform/storyteller/storyteller-base:${BASE_TAG} AS builder

WORKDIR /app

COPY --from=cloner /source/package.json /source/yarn.lock /source/.yarnrc.yml ./
COPY --from=cloner /source/.yarn/releases ./.yarn/releases
COPY --from=cloner /source/.yarn/cache ./.yarn/cache
COPY --from=cloner /source/.yarn/patches ./.yarn/patches

COPY --from=cloner /source/web/package.json ./web/package.json
COPY --from=cloner /source/align/package.json ./align/package.json
COPY --from=cloner /source/align/binding.gyp ./align/binding.gyp
COPY --from=cloner /source/align/prebuilds/linux-x64 ./align/prebuilds/linux-x64
COPY --from=cloner /source/align/prebuilds/linux-arm64 ./align/prebuilds/linux-arm64
COPY --from=cloner /source/fs/package.json ./fs/package.json
COPY --from=cloner /source/epub/package.json ./epub/package.json
COPY --from=cloner /source/path/package.json ./path/package.json
COPY --from=cloner /source/audiobook/package.json ./audiobook/package.json
COPY --from=cloner /source/ghost-story/package.json ./ghost-story/package.json
COPY --from=cloner /source/config/tsup/package.json ./config/tsup/package.json
COPY --from=cloner /source/config/eslint/package.json ./config/eslint/package.json

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

RUN yarn workspaces foreach -Rpt --from @storyteller-platform/web --exclude @storyteller-platform/eslint run build

# Pre-install whisper.cpp binary and default model in builder stage
ARG TARGETARCH
ARG WHISPER_VARIANT
RUN if [ -z "$WHISPER_VARIANT" ]; then \
      case "$TARGETARCH" in \
        amd64) WHISPER_VARIANT="linux-x64-cpu" ;; \
        arm64) WHISPER_VARIANT="linux-arm64-cpu" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
      esac; \
    fi && \
    node ./ghost-story/dist/cli/bin.js \
      install binary "$WHISPER_VARIANT" && \
    node ./ghost-story/dist/cli/bin.js \
      install model tiny.en && \
    if [ "$WHISPER_VARIANT" = "linux-x64-cpu" ]; then \
      echo "Also installing legacy CPU variant for older hardware..." && \
      node ./ghost-story/dist/cli/bin.js \
        install binary linux-x64-cpu-legacy; \
    fi

FROM registry.gitlab.com/storyteller-platform/storyteller/storyteller-base:${BASE_TAG} AS runner

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Force our preferred user (ElfHosted convention: elfie UID/GID 568).
# We don't use upstream's PUID/PGID entrypoint — k8s securityContext pins the UID.
ARG user=elfie
RUN (userdel -r ubuntu 2>/dev/null || true) \
    && groupadd -g 568 $user \
    && useradd --home /home/elfie --create-home --uid 568 --gid 568 --shell /bin/bash $user \
    && (usermod -aG render,video $user 2>/dev/null || true)

COPY --from=readium /opt/readium /opt/readium
RUN ln -sf /opt/readium /usr/local/bin/readium

COPY --from=builder /app/web/.next/standalone ./.next/standalone
COPY --from=builder /app/web/public ./.next/standalone/web/public
COPY --from=builder /app/web/.next/static ./.next/standalone/web/.next/static
COPY --from=builder /app/web/sqlite/uuid.c.so ./.next/standalone/web/sqlite/uuid.c.so

# Copy SQL migrations
COPY --from=builder /app/web/migrations ./.next/standalone/web/migrations

# scripts
# just so its in the right place and we dont have to modify the docs
COPY --from=builder /app/scripts/ ./.next/standalone/web/scripts/

COPY --from=builder /app/align/prebuilds/linux-x64 ./.next/standalone/web/work-dist/@storyteller-platform/align/prebuilds/linux-x64
COPY --from=builder /app/align/prebuilds/linux-arm64 ./.next/standalone/web/work-dist/@storyteller-platform/align/prebuilds/linux-arm64

# Echogarden tries to naively resolve its own wasm builds
COPY --from=builder /app/node_modules/@echogarden/icu-segmentation-wasm/wasm/*.wasm ./.next/standalone/web/work-dist/

# Copy pre-installed whisper binaries and models from builder
COPY --from=builder --chown=568:568 /root/.local/share/ghost-story /home/elfie/.local/share/ghost-story

EXPOSE 8001

ARG VERSION
ENV CI_COMMIT_TAG=web-${VERSION}

ENV HOME=/home/elfie
ENV PORT=8001
ENV HOSTNAME=0.0.0.0
ENV STORYTELLER_DATA_DIR=/data
ENV READIUM_PORT=9000
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV ERROR_ALIGN_NATIVE_BINDING=/app/.next/standalone/web/work-dist/@storyteller-platform/align/
ENV SQLITE_NATIVE_BINDING=/app/.next/standalone/node_modules/better-sqlite3/build/Release/better_sqlite3.node
ENV STORYTELLER_WORKER=worker.cjs
ENV STORYTELLER_FILE_WRITE_WORKER=fileWriteWorker.cjs

# Pre-baked whisper variant this image ships with
ARG WHISPER_VARIANT
ENV STORYTELLER_WHISPER_VARIANT=${WHISPER_VARIANT}

WORKDIR /app/.next/standalone/web

USER 568

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["node", "--enable-source-maps", "server.js"]
