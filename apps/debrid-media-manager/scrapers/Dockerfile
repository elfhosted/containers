# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION
ENV SCRAPERS_SHA=23b3710afa7caa874e00cdaaa9c0494b0e3c774a

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/debridmediamanager/debrid-media-manager.git /source && \
    cd /source && \
    git checkout $SCRAPERS_SHA

# now the original build

FROM node:22-alpine AS dependencies
WORKDIR /app
COPY --from=cloner /source/package*.json ./
RUN npm ci

FROM node:22-alpine AS build
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY --from=cloner /source/. .



RUN npx prisma generate && npm run build

FROM node:22-alpine AS deploy
WORKDIR /app
ENV NODE_ENV production
COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/.next/standalone .
COPY --from=cloner /source/*.txt .
EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"
CMD ["node", "server.js"]
# Combine RUN instructions and install packages
RUN apk --no-cache add curl grep
# Healthcheck as before
HEALTHCHECK --interval=30s --timeout=1s --start-period=3s --retries=1 \
  CMD curl -s http://localhost:3000/api/healthz | grep -qm1 ok

# Switch to postgres
RUN sed -i -e 's/mysql/postgres/' prisma/schema.prisma && \
    sed -i -e 's/mysql/postgres/' node_modules/.prisma/client/schema.prisma && \
    sed -i -e 's/mysql/postgres/' node_modules/.prisma/client/index.js
    
# Apply ElfHosted branding (soon)