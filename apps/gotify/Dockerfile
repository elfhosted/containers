ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:4de1d348d364db1fee3581591cea174c677f68852c7dfd1009583fa1317851dc 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]