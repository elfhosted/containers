ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:abe1c6726d152183da7903907260981392b0feb43bb8238e174a4dbaddcd2f53 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]