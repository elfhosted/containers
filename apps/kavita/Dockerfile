ARG VERSION

FROM kizaing/kavita as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:83295fc8e3abf3d61503b7b694a88f838ab14143e7fe173cde0496a5a3084bc5  

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

WORKDIR /kavita

USER 568

ENTRYPOINT [ "/bin/bash" ]
CMD ["/entrypoint.sh"]