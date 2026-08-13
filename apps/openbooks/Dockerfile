ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:noble-20260730.1@sha256:b6f74509fc1f31dfb5808f261f6187a9597e17a0359c962090366d9649aa62e0 

# default to ephemeral storage
ENV DATA_DIR=/config

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "$DATA_DIR", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


