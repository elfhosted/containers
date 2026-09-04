# RePlay: a single static page that reads a viewer's own Stremio or Nuvio
# record back to them. Source (AGPL-3.0) lives in elfhosted/replay; this
# Dockerfile is published alongside it because the AGPL's corresponding
# source includes the scripts used to build and run the service.
#
# There is no application server. The page talks to the viewer's backend
# from their browser, so all this image does is serve three static files.

FROM alpine:latest AS cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/elfhosted/replay /source

# ---

FROM alpine:3.24

ARG VERSION
ARG user=elfie

# httpd is not in Alpine's stock busybox; it ships in busybox-extras.
RUN apk add --no-cache tini busybox-extras && \
    addgroup -S ${user} -g 568 && adduser -S ${user} -G ${user} -u 568

WORKDIR /app

COPY --from=cloner /source/index.html /source/og.png /source/LICENSE /app/

# Stamp the release into the page so the footer reports what is deployed.
# Fail the build rather than ship a page claiming to be a dev build.
RUN sed -i "s/__REPLAY_VERSION__/${VERSION}/" /app/index.html && \
    ! grep -q "__REPLAY_VERSION__" /app/index.html && \
    chown -R 568:568 /app

USER 568

EXPOSE 8080

# -f keeps httpd in the foreground; tini reaps and forwards signals.
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["httpd", "-f", "-p", "8080", "-h", "/app"]
