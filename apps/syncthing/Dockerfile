ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:28fd4528c834775bc761f7a07f2f73b0338f5007e25bb6cd0289f12d65a2c856 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]