ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:ff81e19bb95c489d057fd02de96d0a37f6f3006a27d4446aba9306bc70b17c00 

# default to ephemeral storage
ENV DATA_DIR=/config

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "$DATA_DIR", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


