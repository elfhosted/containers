ARG VERSION
# Get the source
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://gitlab.com/storyteller-platform/storyteller-base.git /source-storyteller-base
RUN git clone -b web-v$VERSION https://gitlab.com/storyteller-platform/storyteller.git /source

FROM registry.gitlab.com/storyteller-platform/storyteller-base:main AS builder

WORKDIR /app

COPY --from=cloner /source/package.json /source/yarn.lock /source/.yarnrc.yml ./
COPY --from=cloner /source/.yarn/releases ./.yarn/releases
COPY --from=cloner /source/.yarn/cache ./.yarn/cache
COPY --from=cloner /source/.yarn/patches ./.yarn/patches

COPY --from=cloner /source/web/package.json ./web/package.json
COPY --from=cloner /source/fs/package.json ./fs/package.json
COPY --from=cloner /source/epub/package.json ./epub/package.json
COPY --from=cloner /source/path/package.json ./path/package.json
COPY --from=cloner /source/audiobook/package.json ./audiobook/package.json
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

RUN yarn workspaces foreach -Rpt --from @storyteller-platform/web run build

FROM registry.gitlab.com/storyteller-platform/storyteller-base:main AS runner

WORKDIR /app

ARG READIUM_VERSION=0.6.1

# Install Readium CLI using our script
# note: we could also potentially copy it from their docker image
COPY --from=builder /app/web/install-readium-cli.sh /tmp/install-readium-cli.sh
RUN chmod +x /tmp/install-readium-cli.sh && \
    /tmp/install-readium-cli.sh ${READIUM_VERSION} && \
    rm /tmp/install-readium-cli.sh


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

# scripts
# just so its in the right place and we dont have to modify the docs
COPY --from=builder /app/scripts/ ./.next/standalone/web/scripts/

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
ENV READIUM_PORT=9000
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV SQLITE_NATIVE_BINDING=/app/.next/standalone/node_modules/better-sqlite3/build/Release/better_sqlite3.node
ENV STORYTELLER_WORKER=worker.cjs
ENV STORYTELLER_FILE_WRITE_WORKER=fileWriteWorker.cjs

WORKDIR /app/.next/standalone/web

# COPY --from=builder /app/words.txt ./words.txt

ENTRYPOINT ["/usr/bin/tini", "--"]


ARG user=elfie
RUN groupadd -g 568 $user && useradd --home /tmp --uid 568 --gid 568 --shell /bin/bash $user

CMD ["node", "--enable-source-maps", "server.js"]
