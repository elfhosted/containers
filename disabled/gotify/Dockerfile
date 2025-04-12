ARG VERSION
FROM gotify/server:${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:2ba3258c7cc40330bfea13a600ca6762591d677db211a3255fbf44d4635481f0 
COPY --from=upstream /app /app
WORKDIR /app
EXPOSE 80
USER 568
ENTRYPOINT ["./gotify-app"]