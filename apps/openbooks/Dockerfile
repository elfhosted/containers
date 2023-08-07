ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:8a0e46c40c2d2a57ba83cf20409d6a40522358eac14a1b10d55e47b43af28f18 

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENV BOOKS_PATH=/storage/elfstorage/books
ENTRYPOINT ["./openbooks", "server", "--dir", "/storage/elfstorage/downloads/completed", "--port", "8000", "--name", "elfhosted.com", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]
