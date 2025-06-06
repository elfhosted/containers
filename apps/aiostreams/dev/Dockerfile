# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b rewrite  https://github.com/Viren070/AIOStreams.git /source

FROM node:22-alpine AS builder

WORKDIR /build

# Copy LICENSE file.
COPY --from=cloner /source/LICENSE ./

# Copy the relevant package.json and package-lock.json files.
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/packages/server/package*.json ./packages/server/
COPY --from=cloner /source/packages/core/package*.json ./packages/core/
COPY --from=cloner /source/packages/frontend/package*.json ./packages/frontend/

# Install dependencies.
RUN npm install

# Copy source files.
COPY --from=cloner /source/tsconfig.*json ./

COPY --from=cloner /source/packages/server ./packages/server
COPY --from=cloner /source/packages/core ./packages/core
COPY --from=cloner /source/packages/frontend ./packages/frontend
COPY --from=cloner /source/scripts ./scripts

# Build the project.
RUN npm run build

# Remove development dependencies.
RUN npm --workspaces prune --omit=dev

FROM node:22-alpine AS final

WORKDIR /app

# Copy the built files from the builder.
# The package.json files must be copied as well for NPM workspace symlinks between local packages to work.
COPY --from=builder /build/package*.json /build/LICENSE ./

COPY --from=builder /build/packages/core/package.*json ./packages/core/
COPY --from=builder /build/packages/frontend/package.*json ./packages/frontend/
COPY --from=builder /build/packages/server/package.*json ./packages/server/

COPY --from=builder /build/packages/core/dist ./packages/core/dist
COPY --from=builder /build/packages/frontend/out ./packages/frontend/out
COPY --from=builder /build/packages/server/dist ./packages/server/dist

COPY --from=builder /build/resources ./resources

COPY --from=builder /build/node_modules ./node_modules

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:$PORT/api/v1/status || exit 1

EXPOSE $PORT

ENTRYPOINT ["npm", "run", "start"]