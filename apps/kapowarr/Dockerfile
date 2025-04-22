# Get the upstream code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION https://github.com/Casvt/Kapowarr.git  /source

# syntax=docker/dockerfile:1

FROM python:3.8-slim-buster
STOPSIGNAL SIGTERM

RUN \
    adduser elfie \
        --uid 568 \
        --group \
        --system \
        --disabled-password \
        --no-create-home \
    && \
    mkdir -p /config \
    && chown -R elfie:elfie /config \
    && chmod -R 775 /config

USER 568
WORKDIR /config
WORKDIR /app

COPY --from=cloner /source/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY --from=cloner /source/. .

EXPOSE 5656

CMD [ "python3", "/app/Kapowarr.py", "--DatabaseFolder", "/config" ]
