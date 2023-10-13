ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:4ba6fc07eedc670bfca4b2c44f9bff008cba43e67ed53f13ea4a92e1c7b460ef 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]