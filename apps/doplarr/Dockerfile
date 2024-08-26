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
    tzdata \
    tmux \
    ttyd

COPY --from=builder /src/target/doplarr.jar ./

COPY --chown=568:568 apps/doplarr/doplarr.sh /
COPY --chown=568:568 apps/doplarr/launch-tmux.sh /
COPY --chown=568:568 apps/doplarr/entrypoint.sh /
COPY --chown=568:568 apps/doplarr/restricted.tmux.conf /

ENTRYPOINT ["/entrypoint.sh"]