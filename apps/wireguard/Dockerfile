FROM ghcr.io/elfhosted/ubuntu:rolling@sha256:c237763fb7cc7deb53d9484a5941634fbf56a8ed2597bcc3786e875de4c9da6a

ARG VERSION
USER root
COPY ./apps/wireguard/build /build
WORKDIR /tmp

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  export EXTRA_INSTALL_ARG="build-essential git" \
  && apt-get -qq update \
  && \
  apt-get -qq install -y \
    iptables \
    iproute2 \
    openresolv \
    inetutils-ping \
    sudo \
    ${EXTRA_INSTALL_ARG} \
  && git clone https://git.zx2c4.com/wireguard-tools . \
  && git clone https://git.zx2c4.com/wireguard-linux-compat \
  && git checkout "v${VERSION}" \
  && make -C src -j"$(nproc)" \
  && make -C src install \
  && sed -i "s:sysctl -q net.ipv4.conf.all.src_valid_mark=1:# skipping setting net.ipv4.conf.all.src_valid_mark:" /usr/bin/wg-quick \
  && mv /build/sudoers_elfie /etc/sudoers.d/elfie \
  && chown root:root /etc/sudoers.d/* \
  && chmod 644 /etc/sudoers.d/* \
  && \
  apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
    /build \
  && chmod -R u=rwX,go=rX /app \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc

USER 568

COPY ./apps/wireguard/shim/* /shim/
COPY ./apps/wireguard/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
