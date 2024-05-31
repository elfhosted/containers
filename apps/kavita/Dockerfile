ARG VERSION

FROM jvmilazz0/kavita:${VERSION} as upstream
FROM ghcr.io/geek-cookbook/ghcr.io/elfhosted/ubuntu:focal-20240427@sha256:1b84c219a764d8da5ba0f4b2b1f80e7c6396a8c9dfb499f945549396b53b0821  

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