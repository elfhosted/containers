ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:dd5112a70dbae5ae5c53126969b9168c7ef2141576938272f7bff8d194be4823 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]