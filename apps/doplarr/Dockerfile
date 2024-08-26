FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone -b $VERSION https://github.com/kiranshila/Doplarr.git  /source

FROM clojure:tools-deps-1.11.1.1435 as builder

WORKDIR /src

# CACHING DEPS
COPY --from=cloner /source/deps.edn ./
RUN clojure -P
RUN clojure -T:build || true

COPY --from=cloner /source/build/ /src/build/
COPY --from=cloner /source/src/ /src/src/

RUN clojure -T:build uber

FROM eclipse-temurin:22_36-jre-alpine as runtime

WORKDIR /app

RUN \
  apk add --no-cache \
    ca-certificates \
    tini \
    tzdata

COPY --from=builder /src/target/doplarr.jar ./


# Add tmux
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tmux

# Add ttyd
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 /usr/local/bin/ttyd

COPY --chown=568:568 apps/doplarr/doplarr.sh /
COPY --chown=568:568 apps/doplarr/launch-tmux.sh /
COPY --chown=568:568 apps/doplarr/entrypoint.sh /
COPY --chown=568:568 apps/doplarr/restricted.tmux.conf /

ENTRYPOINT ["/entrypoint.sh"]