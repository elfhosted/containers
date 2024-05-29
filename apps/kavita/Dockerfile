ARG VERSION

FROM jvmilazz0/kavita:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:cc288732a39209c6989236163ad29a7247546ac99cd7cd213a6cab2c4de68aa1  

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