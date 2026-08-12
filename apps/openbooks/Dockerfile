ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:dd5112a70dbae5ae5c53126969b9168c7ef2141576938272f7bff8d194be4823 

# default to ephemeral storage
ENV DATA_DIR=/config

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "$DATA_DIR", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


