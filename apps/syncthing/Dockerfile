ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:22c9c87f4e72199aeb63d30175dfed98d97e03797775dd6f9167adf0da3326ed 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]