ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ghcr.io/elfhosted/ubuntu:focal-20240427@sha256:1b84c219a764d8da5ba0f4b2b1f80e7c6396a8c9dfb499f945549396b53b0821 

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "/storage/elfstorage/downloads/completed", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


