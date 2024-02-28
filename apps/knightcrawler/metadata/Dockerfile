FROM alpine:latest as cloner
ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/geek-cookbook/torrentio.elfhosted.com.git /source

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ENV CLONE_PATH=/source/src/metadata
ENV TARGETARCH=linux/amd64

WORKDIR /App
COPY --from=cloner $CLONE_PATH/. ./
RUN dotnet restore -a $TARGETARCH
RUN dotnet publish -c Release --no-restore -o out -a $TARGETARCH

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

WORKDIR /App
COPY --from=build /App/out .
RUN addgroup -S metadata && adduser -S -G metadata metadata
USER metadata
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD pgrep -f dotnet || exit 1
ENTRYPOINT ["dotnet", "Metadata.dll"]
