ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/elfhosted/alpine:rolling@sha256:0782c9e41d6e1efe014e1081a12f9f25665aa9b18372de4bd9bb848ace53cceb 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]