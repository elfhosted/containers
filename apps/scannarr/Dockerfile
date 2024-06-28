# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/Pukabyte/scannarr.git /source

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY --from=cloner /source/*.csproj .
RUN dotnet restore

# copy and publish app and libraries
COPY --from=cloner /source/. .
RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:5.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["./sonarr_scanner"]