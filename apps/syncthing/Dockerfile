ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:90392adc7a86641ddeebd29bcbbfd21b625e84cf7446a33f1628db5fff06918c 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]