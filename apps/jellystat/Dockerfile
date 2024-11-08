# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/CyferShepard/Jellystat.git /source

# Stage 1: Build the application
FROM node:slim AS builder

WORKDIR /app

COPY --from=cloner /source/package*.json ./
RUN npm cache clean --force
RUN npm install

COPY --from=cloner /source/. ./
COPY --from=cloner /source/entry.sh ./

# Build the application
RUN npm run build

# Stage 2: Create the production image
FROM node:slim

WORKDIR /app

COPY --from=builder /app .
COPY --chmod=755 --from=cloner /source/entry.sh /entry.sh

EXPOSE 3000

CMD ["/entry.sh"]