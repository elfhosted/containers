ARG VERSION

FROM kizaing/kavita as upstream
FROM ghcr.io/geek-cookbook/ubuntu:rolling@sha256:4de1d348d364db1fee3581591cea174c677f68852c7dfd1009583fa1317851dc  

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