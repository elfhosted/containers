ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:e92c2494b7c92e6a522a791440642fb25ce160c00906d7ac82efb8e5a5b20044 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]