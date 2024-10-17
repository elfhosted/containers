ARG VERSION

FROM ghcr.io/elfhosted/alpine:rolling@sha256:3904ab32349188d94668bddf41e967d1c0daa0226b848abf35b235555cad2a59

RUN apk add --no-cache aria2

ENTRYPOINT ["/usr/bin/aria2c", "--enable-rpc", "--rpc-listen-all"]
