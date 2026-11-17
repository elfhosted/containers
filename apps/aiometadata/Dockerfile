# Get upstream code - we use node in this case
FROM node:22-alpine as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/cedya77/aiometadata.git /source

# Apply our patches
COPY apps/aiometadata/patches/ /patches/

# Fail the build on any failed patch. Without `set -e` the loop swallows
# `git apply` failures and the image silently ships without some patches.
RUN set -e; cd /source; pn=0; for p in /patches/*.patch; do pn=$((pn+1)); echo "Applying patch $pn"; git apply "$p"; done


FROM node:24-alpine AS builder

WORKDIR /app

COPY --from=cloner /source/package.json /source/package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY --from=cloner /source/. .

# Every environment variable the patches read must be registered or allowlisted.
RUN npm run check:env

# Frontend build, frontend type-check (vite does not type-check), backend build.
RUN npm run build
RUN npx tsc -p tsconfig.app.json --noEmit
RUN npm run build:backend

# Assert each patch reached the compiled output, not merely that it applied.
COPY apps/aiometadata/ci/patch-smoke.cjs /patch-smoke.cjs
RUN node /patch-smoke.cjs /app

FROM node:24-alpine AS runner

WORKDIR /app

LABEL org.opencontainers.image.title="AIOMetadata"
LABEL org.opencontainers.image.source="https://github.com/cedya77/aiometadata"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later AND FSL-1.1-ALv2"

# mimalloc replaces musl's allocator, which holds on to native memory under
# this workload. LD_PRELOAD below keeps RSS bounded without touching app code.
RUN apk add --no-cache ca-certificates mimalloc2

COPY --from=cloner /source/package.json /source/package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund

COPY --from=builder /app/addon ./addon
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public
COPY --from=builder /app/LICENSE /app/LICENSE-FSL.md /app/LICENSING.md /app/NOTICE /app/TRADEMARKS.md /app/THIRD_PARTY_NOTICES.txt ./
COPY --from=builder /app/LICENSES ./LICENSES

ARG PORT=3232
EXPOSE ${PORT}

ENV ENABLE_BUILTIN_POSTER_CACHE=false
ENV LD_PRELOAD=/usr/lib/libmimalloc.so.2

COPY --from=cloner /source /upstream-source
ENTRYPOINT ["node", "dist/server/server.js"]
