ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ghcr.io/elfhosted/ubuntu:focal-20240427@sha256:1b84c219a764d8da5ba0f4b2b1f80e7c6396a8c9dfb499f945549396b53b0821 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]