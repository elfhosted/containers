FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/iPromKnight/flixio-api.git /source

# Build Stage
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS base
ARG TARGETARCH
WORKDIR /build
COPY --from=cloner /source/. .
RUN dotnet restore -a $TARGETARCH
WORKDIR /build/src/Flixio.Api
RUN dotnet publish -c Release --no-restore -a $TARGETARCH -o /app/out

# Run Stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine
RUN apk add --update --no-cache curl
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
ENV WEB_AUTH_KEY=changemeelfie
WORKDIR /app
VOLUME /app/data
COPY --from=base /app/out .
EXPOSE 8080
ENTRYPOINT ["./Flixio.Api"]
