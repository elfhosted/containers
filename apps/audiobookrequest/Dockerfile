# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/markbeep/AudioBookRequest.git /source

# Install daisyui
FROM node:23-alpine3.20

WORKDIR /app

COPY --from=cloner /source/package.json package.json
COPY --from=cloner /source/package-lock.json package-lock.json
RUN npm install

# Setup python
FROM python:3.11-alpine

WORKDIR /app

RUN apk add --no-cache curl gcompat build-base
RUN curl https://github.com/tailwindlabs/tailwindcss/releases/download/v4.0.6/tailwindcss-linux-x64-musl -L -o /bin/tailwindcss
RUN chmod +x /bin/tailwindcss

COPY --from=cloner /source/requirements.txt requirements.txt
RUN pip install -r requirements.txt


COPY --from=0 /app/node_modules/ node_modules/

COPY --from=cloner /source/alembic/ alembic/
COPY --from=cloner /source/alembic.ini alembic.ini
COPY --from=cloner /source/styles/ styles/
COPY --from=cloner /source/static/ static/
COPY --from=cloner /source/templates/ templates/
COPY --from=cloner /source/app/ app/

RUN /bin/tailwindcss -i styles/globals.css -o static/globals.css -m

ENV ABR_APP__PORT=8000

CMD alembic upgrade heads && fastapi run --port $ABR_APP__PORT
