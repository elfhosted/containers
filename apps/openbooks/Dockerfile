ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:cc288732a39209c6989236163ad29a7247546ac99cd7cd213a6cab2c4de68aa1 

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "/storage/elfstorage/downloads/completed", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


