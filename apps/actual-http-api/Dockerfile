# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/jhonderson/actual-http-api.git /source

FROM node:22-alpine AS BUILD_IMAGE

WORKDIR /usr/src/app

COPY --from=cloner /source/package*.json ./

RUN npm install --production
RUN npm ci --omit=dev

COPY --from=cloner /source/. .

FROM node:22-alpine AS RUNNER_IMAGE

WORKDIR /usr/src/app

COPY --from=BUILD_IMAGE /usr/src/app/node_modules ./node_modules
COPY --from=cloner /source/src ./src
COPY --from=cloner /source/package*.json /source/server.js /source/entrypoint.sh ./

RUN chmod +x entrypoint.sh

ENV PORT=5007
ENV ACTUAL_DATA_DIR=/data
ENV NODE_ENV=production

# We need this to exist for goss testing
ENV ACTUAL_SERVER_URL=http://bogus:1234

EXPOSE ${PORT}

ENTRYPOINT [ "./entrypoint.sh" ]