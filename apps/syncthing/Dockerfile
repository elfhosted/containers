ARG VERSION
FROM syncthing/syncthing:${VERSION} as upstream

FROM ghcr.io/geek-cookbook/alpine:rolling@sha256:772358ed7f35cfbc28d07ef76d5261d53ec4296e6198398a37c9af15fcc9ba46 

COPY --from=upstream /bin/syncthing /bin/syncthing

EXPOSE 8384 22000/tcp 22000/udp 21027/udp

# VOLUME ["/media"]

#ENV HOME=/media

ENV STGUIADDRESS=0.0.0.0:8384

ENTRYPOINT ["/bin/syncthing", "--home", "/config", "--no-default-folder"]