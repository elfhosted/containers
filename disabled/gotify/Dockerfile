ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:ff81e19bb95c489d057fd02de96d0a37f6f3006a27d4446aba9306bc70b17c00 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]