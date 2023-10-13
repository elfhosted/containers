ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:4ba6fc07eedc670bfca4b2c44f9bff008cba43e67ed53f13ea4a92e1c7b460ef 

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "/storage/elfstorage/downloads/completed", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


