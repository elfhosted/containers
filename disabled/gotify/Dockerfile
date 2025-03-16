ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:7103ff074d62322cb204b775e2b2b058a0ca1bee97bc1bdc5f0c129e0e10bb66 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]