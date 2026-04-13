FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b v${VERSION} https://github.com/kikootwo/ReadMeABook.git /source

# Build stage
FROM node:20-bookworm-slim AS builder

WORKDIR /app

COPY --from=cloner /source/package.json /source/package-lock.json* ./
COPY --from=cloner /source/prisma ./prisma/

RUN npm ci && npm cache clean --force

COPY --from=cloner /source/. .

ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy?schema=public"
RUN npx prisma generate

ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
ENV TURBOPACK=0
RUN npm run build

# Reorganize for standalone output
RUN cp -r .next/standalone/* . && \
    cp -r .next/static ./.next/static && \
    cp -r public ./public 2>/dev/null || true

RUN npm prune --production

# Install static ffmpeg
ADD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz /tmp/ffmpeg.tar.xz
RUN cd /tmp && tar xf ffmpeg.tar.xz && \
    cp ffmpeg-*-static/ffmpeg ffmpeg-*-static/ffprobe /usr/local/bin/ && \
    rm -rf /tmp/ffmpeg*

# Runtime stage
FROM node:20-bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    openssl \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Create elfie user
RUN groupadd -g 568 elfie && useradd -d /home/elfie --create-home --uid 568 --gid 568 --shell /bin/bash elfie

WORKDIR /app

COPY --from=builder /app /app
COPY --from=builder /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=builder /usr/local/bin/ffprobe /usr/local/bin/ffprobe

RUN mkdir -p /config /app/.next/cache && \
    chown -R elfie:elfie /app /config

USER 568

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3030

EXPOSE 3030

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
