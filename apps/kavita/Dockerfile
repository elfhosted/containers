ARG VERSION

FROM jvmilazz0/kavita:nightly-${VERSION} as upstream
FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:224fbe07e825d0ee91b483bd8403be754971bd0d4813689dbeb28a2435ab46d6  

# for initial install
USER root

COPY --from=upstream /kavita /kavita
# COPY --from=upstream /kavita/wwwroot /kavita/wwwroot
COPY ./apps/kavita/entrypoint.sh /entrypoint.sh

#Installs program dependencies
RUN apt-get update \
  && apt-get install -y libicu-dev libssl1.1 libgdiplus curl \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 5000

# To make it work with a readonly filesystem, see https://github.com/dotnet/docs/issues/10217
ENV COMPlus_EnableDiagnostics=0

# Not sure what this does but it looks relevant
ENV DOTNET_RUNNING_IN_CONTAINER=true

WORKDIR /kavita

USER 568

ENTRYPOINT [ "/bin/bash" ]
CMD ["/entrypoint.sh"]