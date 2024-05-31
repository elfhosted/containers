FROM alpine:latest as cloner

ARG CHANNEL

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  -b $CHANNEL https://github.com/geek-cookbook/torrentio.elfhosted.com.git /tmp/source

FROM node:lts-buster-slim

# RUN apk update && apk upgrade && \
#     apk add --no-cache git curl

RUN apt-get update && \
    apt-get install -y curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home/node/app

COPY --from=cloner /tmp/source/src/node/consumer/package*.json ./
RUN npm ci --only-production
COPY --from=cloner /tmp/source/src/node/consumer .
RUN chmod a+x ./check-ip.sh

CMD [ "node", "--no-warnings=ExperimentalWarning", "index.js" ]








