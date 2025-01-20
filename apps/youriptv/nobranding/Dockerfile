# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/mikmc55/epgtv.git /source

COPY apps/youriptv/manifest.js /source/

# Copy tweaked addon.js (20s timeout, branding
COPY apps/youriptv/addon.js /source/

FROM node:18.16.0-alpine as base

WORKDIR /app

COPY --from=cloner /source/package*.json ./

RUN npm install

COPY --from=cloner /source .

# ENV NODE_ENV local  # see https://github.com/mikmc55/epgtv/blob/0457abb4bf5c0cea421026fba313c8708efb688e/config.js#L1

EXPOSE 3649

CMD [ "node", "index.js" ]