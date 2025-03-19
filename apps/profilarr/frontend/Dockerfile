# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Dictionarry-Hub/profilarr.git /source

FROM node:18

WORKDIR /app

# cache dir in final
ENV CACHE_DIR=/app/build-cache

COPY --from=cloner /source/frontend/package*.json ./
RUN npm install

COPY --from=cloner /source/frontend/. .

COPY apps/profilarr/frontend/vite.config.js .

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]