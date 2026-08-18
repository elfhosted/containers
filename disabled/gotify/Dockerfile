ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:bb9a70388f6b6be4fd43cb34aa6abe15595323e76cd989c7e5cac04bb2193e5d 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]