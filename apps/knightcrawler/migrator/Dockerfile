# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION --depth 1 https://github.com/knightcrawler-stremio/knightcrawler.git /source

FROM ghcr.io/peterldowns/pgmigrate:latest
USER root
RUN addgroup -S migrator && adduser -S -G migrator migrator
USER migrator
WORKDIR /tmp
COPY --chmod=0777 --from=cloner /source/src/migrator/. .
ENTRYPOINT [ "./entrypoint.sh" ]