# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/tapframe/Nuvio-Proxy.git /source

FROM node:20-alpine as base
WORKDIR /app

# Build layer
FROM base as build

RUN npm i -g pnpm
COPY --from=cloner /source/pnpm-lock.yaml /source/package.json ./
RUN pnpm install --frozen-lockfile
COPY --from=cloner /source/. .
RUN pnpm build

# Production layer
FROM base as production

EXPOSE 3000
ENV NODE_ENV=production
COPY --from=build /app/.output ./.output

# Force our preferred user
ARG user=elfie
RUN addgroup -S elfie --gid 568 && adduser -S elfie -G elfie --uid 568
USER 568

CMD ["node", ".output/server/index.mjs"]