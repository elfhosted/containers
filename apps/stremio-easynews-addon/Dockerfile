# Get the upstream code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/sleeyax/stremio-easynews-addon.git /source
FROM node:22-alpine AS builder

WORKDIR /build

# Copy LICENSE file.
COPY --from=cloner /source/LICENSE ./

# Copy the relevant package.json and package-lock.json files.
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/packages/api/package*.json ./packages/api/
COPY --from=cloner /source/packages/addon/package*.json ./packages/addon/

# Install dependencies.
RUN npm install

# Copy source files.
COPY --from=cloner /source/tsconfig.*json ./
COPY --from=cloner /source/packages/api ./packages/api
COPY --from=cloner /source/packages/addon ./packages/addon

# Build the project.
RUN npm run build

# Remove development dependencies.
RUN npm --workspaces prune --omit=dev

FROM node:22-alpine AS final

WORKDIR /app

# Copy the built files from the builder.
# The package.json files must be copied as well for NPM workspace symlinks between local packages to work.
COPY --from=builder /build/package*.json /build/LICENSE ./
COPY --from=builder /build/packages/addon/package.*json ./packages/addon/
COPY --from=builder /build/packages/api/package.*json ./packages/api/
COPY --from=builder /build/packages/addon/dist ./packages/addon/dist
COPY --from=builder /build/packages/api/dist ./packages/api/dist

COPY --from=builder /build/node_modules ./node_modules

EXPOSE 1337

ENTRYPOINT ["npm", "run", "start:addon"]
