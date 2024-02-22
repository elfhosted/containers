# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://github.com/geek-cookbook/debridmediamanager.git /source

FROM node:18-alpine AS dependencies

WORKDIR /app
COPY --from=cloner /source/package.json package-lock.json ./
RUN npm ci

FROM node:18-alpine AS build

WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=cloner /source .

RUN npx prisma generate
RUN npm run build

FROM node:18-alpine AS deploy

WORKDIR /app

ENV NODE_ENV production

COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/.next/standalone .

EXPOSE 3000

ENV PORT 3000
# set hostname to localhost
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]

# Install additional tools (curl and grep)
RUN apk --no-cache add curl grep

# Healthcheck
HEALTHCHECK --interval=30s --timeout=1s --start-period=3s --retries=1 \
  CMD curl -s http://localhost:3000/api/healthz | grep -qm1 ok
