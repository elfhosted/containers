ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:224fbe07e825d0ee91b483bd8403be754971bd0d4813689dbeb28a2435ab46d6 

# default to ephemeral storage
ENV DATA_DIR=/config

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "$DATA_DIR", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


