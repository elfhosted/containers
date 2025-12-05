# Get upstream code
FROM alpine:latest as cloner
ARG VERSION
ARG CACHE_BUST=1

RUN apk update && apk upgrade && \
    apk add --no-cache git && \
    echo "cache bust: ${CACHE_BUST}"

RUN git clone https://github.com/funkypenguin/stremio-internet-archive-addon.git /source

FROM node:20-slim

WORKDIR /app
ENV NODE_ENV=production

COPY --from=cloner /source/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=cloner /source/ .

EXPOSE 7000
CMD ["node", "server.js"]
