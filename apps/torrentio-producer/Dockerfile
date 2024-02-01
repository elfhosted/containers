FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /App

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /App

ENV PORT 7001

RUN git clone  -b $CHANNEL https://github.com/geek-cookbook/torrentio.elfhosted.com.git /tmp/source && \
    cp -rf /tmp/source/${CHANNEL}/* . && \
    rm -rf /tmp/source

RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /App
COPY --from=build-env /App/out .
ENTRYPOINT ["dotnet", "Producer.dll"]