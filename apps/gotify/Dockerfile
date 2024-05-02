ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:cc288732a39209c6989236163ad29a7247546ac99cd7cd213a6cab2c4de68aa1 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]