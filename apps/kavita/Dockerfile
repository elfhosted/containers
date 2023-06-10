ARG VERSION

FROM kizaing/kavita as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:dce9a402b9fde42298f7b5079c5bb37a865118b81f3996cac117b90db203c1b4 

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