# harbor-site: harbor.site's apex marketing site, served from Backblaze B2.
#
# Unlike the nine harbor-* backends this clones no source. The whole artifact is
# an nginx configuration plus one njs module. The SITE CONTENT is not in the
# image and must not be: it is 114 MB of images and video, it changes without any
# code change, and baking it in would make every content edit an image rebuild.
# It lives in the elfhosted-harbor bucket under ${HARBOR_S3_PREFIX}site/ and is
# fetched per request.
#
# BECAUSE NOTHING HERE IS VERSIONED UPSTREAM, ci/latest.sh emits a hand-written
# version and that version is the ONLY lever that moves this image. Change
# anything in this directory and bump it, or the build produces new contents
# under an unchanged tag, Flux has nothing to act on, and imagePullPolicy
# IfNotPresent reuses the cached layer even across a restart -- the same trap
# harbor-hosted's HANDOVER.md documents in §2.

FROM nginxinc/nginx-unprivileged:1.29-alpine

# Recorded for the label only; there is no source checkout to pin. The image is
# still tagged with it by action-image-build.yaml.
ARG VERSION

USER root

# The stock server block listens on the same port and would answer first.
RUN rm -f /etc/nginx/conf.d/default.conf

# Build context is the repository root (action-image-build.yaml runs
# `docker buildx build … .`), so these paths are repo-relative, not
# Dockerfile-relative.
COPY apps/harbor-site/nginx.conf                   /etc/nginx/nginx.conf
COPY apps/harbor-site/harbor-site.conf             /etc/nginx/conf.d/harbor-site.conf
COPY apps/harbor-site/harbor-origin.conf           /etc/nginx/snippets/harbor-origin.conf
COPY apps/harbor-site/harbor-site.js               /etc/nginx/njs/harbor-site.js
COPY apps/harbor-site/05-harbor-site-resolver.sh   /docker-entrypoint.d/05-harbor-site-resolver.sh

# Shadow the bucket's copies of these two, which name a third domain that
# redirects back here. Baked in rather than fixed in the bucket because the
# bucket re-syncs from the VPS every 6h and would revert it. See the header
# comment in each file.
COPY apps/harbor-site/robots.txt                   /usr/share/nginx/seo/robots.txt
COPY apps/harbor-site/sitemap.xml                  /usr/share/nginx/seo/sitemap.xml

RUN chmod 0755 /docker-entrypoint.d/05-harbor-site-resolver.sh \
 && chmod 0644 /etc/nginx/nginx.conf \
               /etc/nginx/conf.d/harbor-site.conf \
               /etc/nginx/snippets/harbor-origin.conf \
               /etc/nginx/njs/harbor-site.js \
               /usr/share/nginx/seo/robots.txt \
               /usr/share/nginx/seo/sitemap.xml

# `nginx -t` at build time, so a config that cannot parse fails the build rather
# than CrashLooping in the cluster. It needs the resolver include to exist, and
# at build time there is no pod /etc/resolv.conf to derive one from, so a
# throwaway file stands in.
#
# EMPTYING /tmp AFTERWARDS IS NOT TIDYING, IT IS THE POINT. This RUN is root, and
# `nginx -t` does not just parse: it creates /tmp/nginx.pid and the five *_temp
# directories, all root-owned, alongside the /tmp/nginx this line makes itself.
#
# In the cluster an emptyDir mounts over /tmp and hides every one of them. With
# NO mount -- which is exactly how `dgoss run` starts this image in CI -- they
# survive into the running container, where the process is UID 101 and cannot
# write any of them. The entrypoint's redirect fails first, or if that is fixed
# alone, nginx dies on `open() "/tmp/nginx.pid" failed (13: Permission denied)`.
# Either way the container exits before serving anything, so this breaks the
# smoke test and only the smoke test -- the worst possible place for it, because
# the deployed thing would have been fine and the signal would read as a bad
# image.
#
# `find -mindepth 1 -delete` rather than `rm -rf /tmp`, which would take the
# directory's 1777 with it.
RUN mkdir -p /tmp/nginx \
 && printf 'resolver 127.0.0.11 valid=30s ipv6=off;\nresolver_timeout 5s;\n' > /tmp/nginx/resolver.conf \
 && nginx -t \
 && find /tmp -mindepth 1 -delete

# 101 is nginx-unprivileged's `nginx` user. Pinned by number as well as name so a
# base-image change cannot silently promote this to root.
USER 101:101

# 8080 and WILDCARD-bound -- see the listen directives in harbor-site.conf.
# nginx-unprivileged cannot bind 80.
EXPOSE 8080

# /healthz is answered by nginx itself and never touches B2, so this reports this
# server's health rather than Backblaze's.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

STOPSIGNAL SIGQUIT

# Per-build identity (version, revision, created) is applied as --label by
# action-image-build.yaml, which is the only thing that knows those values.
LABEL org.opencontainers.image.title="harbor-site" \
      org.opencontainers.image.description="Harbor's apex marketing site, served from object storage"
