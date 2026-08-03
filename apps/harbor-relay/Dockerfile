# syntax=docker/dockerfile:1
#
# harbor-relay: the public Watch Together relay (wss://pub.harbor.site).
#
# PORTED FROM harbor-hosted deploy/relay/Dockerfile, with one substantive change:
# that file states its build context is "a checkout of harborstremio/
# pub.harbor.site", which stopped being true when the relay was vendored. The
# source now lives at services/harbor-relay/src/ in harbor-hosted, so this clones
# harbor-hosted at the release tag like every other vendored service here.
#
# WHY THIS FILE EXISTS AT ALL. Nothing built harbor-relay. harbor-hosted retired
# build-images.yml when image builds moved to elfhosted/containers, but the relay
# was never added on this side -- so it has no build path in either repo. The
# running harbor-relay-v0.3.0 predates the retirement, and cutting v0.4.0 would
# have produced a git tag with no image behind it and nothing reporting a
# problem.
#
# uWebSockets.js resolves from a GitHub tag and compiles a native binding, so the
# build stage needs git and a toolchain. The runtime stage does not.

FROM alpine:latest AS cloner
ARG VERSION
ARG ZURG_GH_CREDS
RUN apk add --no-cache git
RUN echo "harbor-hosted @ ${VERSION}" \
 && git clone "https://${ZURG_GH_CREDS}@github.com/harborstremio/harbor-hosted.git" /source \
 && git -C /source checkout --detach "${VERSION}"

FROM node:20-bookworm-slim AS build
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates python3 build-essential \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
# package-lock.json comes across too: npm ci refuses to run without it, and the
# native binding is pinned there rather than in package.json.
COPY --from=cloner /source/services/harbor-relay/src/package.json /source/services/harbor-relay/src/package-lock.json ./
RUN npm ci --omit=dev
COPY --from=cloner /source/services/harbor-relay/src/src ./src

FROM node:20-bookworm-slim AS runtime
ENV NODE_ENV=production
# TCP rather than the unix socket the VPS used. Both are supported and they are
# mutually exclusive, so RELAY_UNIX_SOCKET stays unset.
ENV RELAY_HOST=0.0.0.0
ENV RELAY_PORT=8080
# Client IPs arrive via the forwarded header, so per-IP limits apply to the real
# client rather than to the ingress.
ENV RELAY_TRUST_PROXY=1

WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=cloner /source/services/harbor-relay/src/package.json ./

# The systemd unit set LimitNOFILE=200000. Each WebSocket is one fd and the relay
# ceiling is RELAY_CONN_MAX (default 40000), so a runtime default of 1024 refuses
# connections in the low thousands and presents as a network fault rather than a
# limit. There is no pod-level field for this in Kubernetes -- it is set on the
# node or the runtime class, which is why this is a comment and not a directive.

USER node
EXPOSE 8080

# No disk writes, no children, no persistence -- nothing to preserve on stop.
STOPSIGNAL SIGTERM

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["node","-e","fetch('http://127.0.0.1:8080/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]

LABEL org.opencontainers.image.title="harbor-relay" \
      org.opencontainers.image.description="Harbor Watch Together relay (uWebSockets.js)"

CMD ["node", "src/server.js"]
