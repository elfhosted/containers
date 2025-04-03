# =============================================================================
# Build stage
# =============================================================================

FROM node:22-bullseye AS builder

ARG VERSION

RUN apt-get update \
    && apt-get install -y \
    python tini git \
    && rm -rf /var/lib/apt/lists/*

# Enables Yarn
RUN corepack enable

RUN git clone  --branch $VERSION https://github.com/laurent22/joplin.git /source
WORKDIR /build

RUN mkdir .yarn && \
    mkdir -p .packages/server && \
    cp -rf /source/.yarn/plugins ./.yarn/plugins && \
    cp -rf /source/.yarn/releases ./.yarn/releases && \
    cp -rf /source/.yarn/patches ./.yarn/patches && \
    cp -rf /source/package.json . && \
    cp -rf /source/.yarnrc.yml . && \
    cp -rf /source/yarn.lock . && \
    cp -rf /source/gulpfile.js . && \
    cp -rf /source/tsconfig.json . && \
    cp -rf /source/packages/turndown ./packages/ && \
    cp -rf /source/packages/turndown-plugin-gfm ./packages/ && \
    cp -rf /source/packages/fork-htmlparser2 ./packages/ && \
    cp -rf /source/packages/server ./packages/ && \
    cp -rf /source/packages/fork-sax ./packages/ && \
    cp -rf /source/packages/fork-uslug ./packages/ && \
    cp -rf /source/packages/htmlpack ./packages/ && \
    cp -rf /source/packages/renderer ./packages/ && \
    cp -rf /source/packages/tools ./packages/ && \
    cp -rf /source/packages/utils ./packages/ && \
    cp -rf /source/packages/lib ./packages/ 


# # For some reason there's both a .yarn/cache and .yarn/berry/cache that are
# # being generated, and both have the same content. Not clear why it does this
# # but we can delete it anyway. We can delete the cache because we use
# # `nodeLinker: node-modules`. If we ever implement Zero Install, we'll need to
# # keep the cache.
# #
# # Note that `yarn install` ignores `NODE_ENV=production` and will install dev
# # dependencies too, but this is fine because we need them to build the app.

RUN BUILD_SEQUENCIAL=1 yarn install --inline-builds \
    && yarn cache clean \
    && rm -rf .yarn/berry

# # =============================================================================
# # Final stage - we copy only the relevant files from the build stage and start
# # from a smaller base image.
# # =============================================================================

FROM node:22-bullseye-slim

ARG user=elfie
RUN groupadd -g 568 $user && useradd --create-home --uid 568 --gid 568 --shell /bin/bash $user


USER $user

COPY --chown=$user:$user --from=builder /build/packages /home/$user/packages
COPY --chown=$user:$user --from=builder /usr/bin/tini /usr/local/bin/tini

ENV NODE_ENV=production
ENV RUNNING_IN_DOCKER=1

# Use Tini to start Joplin Server:
# https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md#handling-kernel-signals
WORKDIR /home/$user/packages/server
ENTRYPOINT ["tini", "--"]
CMD ["node", "dist/app.js"]

# Build-time metadata
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
ARG BUILD_DATE
ARG REVISION
ARG VERSION
LABEL org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.title="Joplin Server" \
      org.opencontainers.image.description="Docker image for Joplin Server" \
      org.opencontainers.image.url="https://joplinapp.org/" \
      org.opencontainers.image.revision="$REVISION" \
      org.opencontainers.image.source="https://github.com/laurent22/joplin.git" \
      org.opencontainers.image.version="${VERSION}"