# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/anmol210202/rating-aggregator-.git /source

# --- frontend builder ---
FROM node:18-alpine AS frontend-builder

# ARG VITE_HOME_BLURB
ENV VITE_HOME_BLURB=<img src="https://elfhosted.com/images/logo.svg" height="128px" width="128px" style="float: left; margin-right: 10px;"/><p>This is the public instance of <a href="https://github.com/anmol210202/rating-aggregator-/">Rating Aggregator</a>, sponsored by <a href="https://store.elfhosted.com/">ElfHosted</a> ❤️ <br/>See our FREE <a href="https://stremio-addons-guide.elfhosted.com">Stremio Addons Guide</a> for more great addons and features!</p>

WORKDIR /app

COPY --from=cloner /source/frontend/package.json /source/frontend/package-lock.json ./frontend/
RUN cd frontend && npm ci

COPY --from=cloner /source/frontend ./frontend

# Inject VITE_HOME_BLURB into Vite
COPY apps/rating-aggregator/blurb.env frontend/.env.production
# RUN printf "VITE_HOME_BLURB=%s\n" "${VITE_HOME_BLURB}" > frontend/.env.production \
# && echo "--- frontend/.env.production contents ---" \
# && cat frontend/.env.production

RUN cd frontend && npm run build

# --- backend builder ---
FROM node:18-alpine AS backend-builder
WORKDIR /app

COPY --from=cloner /source/package.json /source/package-lock.json ./
RUN npm ci --production

# --- final image ---
FROM node:18-alpine
WORKDIR /app

RUN apk add --no-cache curl

COPY --from=frontend-builder /app/frontend/dist ./frontend/dist
COPY --from=backend-builder /app/node_modules ./node_modules

COPY --from=cloner /source/package.json .
COPY --from=cloner /source/src ./src
COPY --from=cloner /source/api ./api

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
CMD curl -f http://localhost:$PORT/ || exit 1

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

CMD ["npm", "start"]
    