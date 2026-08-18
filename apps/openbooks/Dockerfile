ARG VERSION
FROM ghcr.io/evan-buss/openbooks:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:bb9a70388f6b6be4fd43cb34aa6abe15595323e76cd989c7e5cac04bb2193e5d 

# default to ephemeral storage
ENV DATA_DIR=/config

WORKDIR /app
COPY --from=upstream /app/openbooks /app/openbooks
ENTRYPOINT ["./openbooks", "server", "--dir", "$DATA_DIR", "--port", "8000", "--name", "elfhosted-user", "--tls=false", "--persist", "-s irc.irchighway.net:6660", "--no-browser-downloads"]


