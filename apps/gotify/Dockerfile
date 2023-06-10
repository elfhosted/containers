ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:dce9a402b9fde42298f7b5079c5bb37a865118b81f3996cac117b90db203c1b4
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]