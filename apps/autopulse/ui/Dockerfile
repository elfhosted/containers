# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/dan-online/autopulse.git /source

FROM public.ecr.aws/docker/library/node:23-alpine AS builder
WORKDIR /app
COPY --from=cloner /source/ui/package.json .
COPY --from=cloner /source/ui/yarn.lock .

RUN corepack enable
RUN yarn config set nodeLinker node-modules
RUN yarn install --immutable

COPY --from=cloner /source/ui/. .

RUN yarn build
RUN rm -rf node_modules
RUN yarn workspaces focus --production

FROM public.ecr.aws/docker/library/node:23-alpine
WORKDIR /app
COPY --from=builder /app/build build/
COPY --from=builder /app/node_modules node_modules/
COPY --from=cloner /source/ui/package.json .

ENV PORT=2880

EXPOSE 2880

ENV NODE_ENV=production
CMD [ "node", "build" ]