# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION --depth 1 https://github.com/knightcrawler-stremio/knightcrawler.git /source

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ARG TARGETARCH
WORKDIR /src
COPY --from=cloner /source/src/shared/ shared/
COPY --from=cloner /source/src/torrent-consumer/ torrent-consumer/
WORKDIR /src/torrent-consumer/
RUN dotnet restore -a $TARGETARCH
RUN dotnet publish -c Release --no-restore -o /src/out -a $TARGETARCH


FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

WORKDIR /app
COPY --from=build /src/out .
RUN addgroup -S consumer && adduser -S -G consumer consumer
USER consumer
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD pgrep -f dotnet || exit 1
ENTRYPOINT ["dotnet", "TorrentConsumer.dll"]