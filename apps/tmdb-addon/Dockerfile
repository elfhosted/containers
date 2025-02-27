# Get the elfhosted code
FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone  https://github.com/mrcanelas/tmdb-addon.git /source

COPY apps/tmdb-addon/elfhosted.patch /

# Apply ElfHosted tweaks
RUN cd /source && \
    git apply /elfhosted.patch

## Upstream Dockerfile

# Etapa de construção do frontend
FROM node:22-alpine AS builder

WORKDIR /app

# Copia os arquivos de configuração primeiro
COPY --from=cloner /source/package*.json ./

# Instala as dependências
RUN npm install

# Copia o restante do código fonte
COPY --from=cloner /source/. .

# Build da aplicação React
RUN npm run build

# Etapa de produção
FROM node:18-alpine AS runner

ENV FANART_API=setme
ENV PORT=3000

WORKDIR /app

# Copia apenas os arquivos necessários
COPY --from=cloner /source/package*.json ./

# Instala apenas dependências de produção
RUN npm install --production

# Copia os arquivos do servidor
COPY --from=builder /app/addon ./addon

# Copia os arquivos buildados do React
COPY --from=builder /app/dist ./dist

# Copia a pasta public com as imagens
COPY --from=builder /app/configure/public ./public

# Comando para iniciar o servidor
ENTRYPOINT ["node", "addon/server.js"]