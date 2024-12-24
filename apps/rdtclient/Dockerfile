# Stage 1 - Build the frontend
FROM node:22-alpine3.18 AS node-build-env
ARG VERSION
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
ARG BUILDPLATFORM
ENV BUILDPLATFORM=${BUILDPLATFORM:-linux/amd64}

RUN mkdir /appclient
WORKDIR /appclient

RUN apk add --no-cache git python3 py3-pip make g++

RUN \
   echo "**** Cloning Source Code ****" && \
   git clone  --branch ${VERSION} https://github.com/rogerfar/rdt-client.git . && \
   cd client && \
   echo "**** Building Code  ****" && \
   npm ci && \
   npx ng build --output-path=out

RUN ls -FCla /appclient/root

# Stage 2 - Build the backend
FROM mcr.microsoft.com/dotnet/sdk:9.0-bookworm-slim-amd64 AS dotnet-build-env
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
ARG BUILDPLATFORM
ENV BUILDPLATFORM=${BUILDPLATFORM:-linux/amd64}

RUN mkdir /appserver
WORKDIR /appserver

RUN \
   echo "**** Cloning Source Code ****" && \
   git clone https://github.com/rogerfar/rdt-client.git . && \
   echo "**** Building Source Code for $TARGETPLATFORM on $BUILDPLATFORM ****" && \
   cd server && \
   dotnet restore --no-cache RdtClient.sln && dotnet publish --no-restore -c Release -o out ; 

# Stage 3 - Build runtime image
FROM ghcr.io/elfhosted/alpine:rolling@sha256:672b59dc4580b8aaae42e839c878501109ed7a810072c872363250930899bf16 
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
ARG BUILDPLATFORM
ENV BUILDPLATFORM=${BUILDPLATFORM:-linux/amd64}

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io extended version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="ravensorb"

# set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"
ENV RDTCLIENT_BRANCH="main"

RUN \
   mkdir -p /storage /config || true && \
   echo "**** Updating package information ****" && \
   apk update && \
   echo "**** Install pre-reqs ****" && \
   apk add bash icu-libs krb5-libs libgcc libintl libssl3 libstdc++ zlib && \
   echo "**** Installing dotnet ****" && \
   mkdir -p /usr/share/dotnet

RUN \
   if [ "$TARGETPLATFORM" = "linux/arm/v7" ] ; then \
   wget https://download.visualstudio.microsoft.com/download/pr/59a041e1-921e-405e-8092-95333f80f9ca/63e83e3feb70e05ca05ed5db3c579be2/aspnetcore-runtime-9.0.0-linux-musl-arm.tar.gz && \
   tar zxf aspnetcore-runtime-9.0.0-linux-musl-arm.tar.gz -C /usr/share/dotnet ; \
   elif [ "$TARGETPLATFORM" = "linux/arm64" ] ; then \
   wget https://download.visualstudio.microsoft.com/download/pr/e137f557-83cb-4f55-b1c8-e5f59ccd3cba/b8ba6f2ab96d0961757b71b00c201f31/aspnetcore-runtime-9.0.0-linux-musl-arm64.tar.gz && \
   tar zxf aspnetcore-runtime-9.0.0-linux-musl-arm64.tar.gz -C /usr/share/dotnet ; \
   else \
   wget https://download.visualstudio.microsoft.com/download/pr/86d7a513-fe71-4f37-b9ec-fdcf5566cce8/e72574fc82d7496c73a61f411d967d8e/aspnetcore-runtime-9.0.0-linux-musl-x64.tar.gz && \
   tar zxf aspnetcore-runtime-9.0.0-linux-musl-x64.tar.gz -C /usr/share/dotnet ; \
   fi
	
RUN rm -rf \
        /tmp/* \
        /var/cache/apk/* \
        /var/tmp/* || true

ENV PATH "$PATH:/usr/share/dotnet"

USER 568 

# /data has to exist for tests
WORKDIR /data
RUN mkdir db && mkdir logs

# Copy files for app
WORKDIR /app
COPY --from=dotnet-build-env /appserver/server/out .
COPY --from=node-build-env /appclient/client/out ./wwwroot
COPY --from=node-build-env /appclient/root/ /

# ports and volumes
EXPOSE 6500

COPY ./apps/rdtclient/entrypoint.sh /entrypoint.sh
COPY ./apps/rdtclient/appsettings.json /app/

CMD ["/entrypoint.sh"]