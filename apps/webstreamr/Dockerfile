# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/webstreamr/webstreamr /source

FROM node:22.17-alpine AS builder
WORKDIR /app

COPY --from=cloner /source/package*.json ./
RUN npm ci

COPY --from=cloner /source/tsconfig.json ./
COPY --from=cloner /source/src ./src
RUN npm run build

RUN npm ci --only=production

FROM node:22.17-alpine
WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

ENV NODE_ENV=production

CMD ["node", "dist/index.js"]
