ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:a03913e04428c49195fa0b4c9a6e7cfad889692b4839937b387b0a2a06f25733 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]