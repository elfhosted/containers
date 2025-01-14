# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Viren070/AIOStreams.git /source

FROM node:22-alpine AS builder

WORKDIR /build

# Copy LICENSE file.
COPY --from=cloner /source/LICENSE ./

# Copy the relevant package.json and package-lock.json files.
COPY --from=cloner /source/package*.json ./
COPY --from=cloner /source/packages/formatters/package*.json ./packages/formatters/
COPY --from=cloner /source/packages/parser/package*.json ./packages/parser/
COPY --from=cloner /source/packages/types/package*.json ./packages/types/
COPY --from=cloner /source/packages/wrappers/package*.json ./packages/wrappers/
COPY --from=cloner /source/packages/addon/package*.json ./packages/addon/
COPY --from=cloner /source/packages/frontend/package*.json ./packages/frontend/
COPY --from=cloner /source/packages/utils/package*.json ./packages/utils/


# Install dependencies.
RUN npm install

# Copy source files.
COPY --from=cloner /source/tsconfig.*json ./

COPY --from=cloner /source/packages/addon ./packages/addon
COPY --from=cloner /source/packages/formatters ./packages/formatters
COPY --from=cloner /source/packages/parser ./packages/parser
COPY --from=cloner /source/packages/types ./packages/types
COPY --from=cloner /source/packages/wrappers ./packages/wrappers
COPY --from=cloner /source/packages/frontend ./packages/frontend
COPY --from=cloner /source/packages/utils ./packages/utils

ENV NEXT_PUBLIC_ELFHOSTED_BRANDING << EOT

This is an <A HREF="https://elfhosted.com">ElfHosted</A> instance of AIOStreams, for the Stremio Community - Enjoy! ❤️ </BR>(<I>reasonable <A HREF="https://github.com/elfhosted/infra/blob/main/traefik-middleware/middleware-rate-limit-public-stremio-addon.yaml">rate-limits</A> apply</I>)
<br/><br/>What is ElfHosted?

<p><a href="https://elfhosted.com/">ElfHosted</a> is an <a href="https://elfhosted.com/open/">open-source</a> platform for <A HREF="https://elfhosted.com/guides/media/">"self-hosting" Plex with Real Debrid</A> (<I>using <A HREF="https://elfhosted.com/guides/media/stream-from-real-debrid-with-plex/">plex_debrid</A>, <A HREF="https://elfhosted.com/guides/media/stream-from-real-debrid-with-plex-riven/">Riven</A>, or <A HREF="https://elfhosted.com/guides/media/stream-from-real-debrid-with-plex-radarr-sonarr-prowlarr/">Radarr & Sonarr</A></I>), and your <a href="https://elfhosted.com/apps/">awesome self-hosted apps</a>, automatically and easily.</p>
<br/>
<p>We support the Stremio community (<A HREf="https://reddit.com/r/StremioAddons">Reddit</A> / <A HREF="https://discord.gg/zNRf6YF">Discord</A>) by providing free hosting for some of the <A HREF="https://elfhosted.com/stremio-addons/">best Stremio Addons</A>, including those which enable you to:</p>
👨‍👩‍👦‍👦 <A HREF="https://elfhosted.com/app/comet/">Share your Real Debrid / Stremio from multiple locations at once</A> (<I>Comet</I>)
<br/>🎁 Watch your paid <A HREF="https://elfhosted.com/app/xtremio/">IPTV with Stremio</A> (<I>Xtremio</I>)
<br/>📺 Install a <A HREF="https://elfhosted.com/app/mediafusion/">Stremio Live TV addon</A> (<I>MediaFusion</I>)
<br/>🏈 Watch recorded / live <A HREF="https://elfhosted.com/app/mediafusion/">sports with Stremio</A> (<I>MediaFusion</I>)
EOT

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
COPY --from=builder /build/packages/frontend/package.*json ./packages/frontend/
COPY --from=builder /build/packages/formatters/package.*json ./packages/formatters/
COPY --from=builder /build/packages/parser/package.*json ./packages/parser/
COPY --from=builder /build/packages/types/package.*json ./packages/types/
COPY --from=builder /build/packages/wrappers/package.*json ./packages/wrappers/
COPY --from=builder /build/packages/utils/package.*json ./packages/utils/


COPY --from=builder /build/packages/addon/dist ./packages/addon/dist
COPY --from=builder /build/packages/frontend/out ./packages/frontend/out
COPY --from=builder /build/packages/formatters/dist ./packages/formatters/dist
COPY --from=builder /build/packages/parser/dist ./packages/parser/dist
COPY --from=builder /build/packages/types/dist ./packages/types/dist
COPY --from=builder /build/packages/wrappers/dist ./packages/wrappers/dist
COPY --from=builder /build/packages/utils/dist ./packages/utils/dist

COPY --from=builder /build/node_modules ./node_modules

EXPOSE 3000

ENTRYPOINT ["npm", "run", "start:addon"]