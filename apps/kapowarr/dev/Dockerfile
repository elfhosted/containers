# Get the upstream code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b development https://github.com/Casvt/Kapowarr.git  /source

# syntax=docker/dockerfile:1

FROM python:3.8-slim-buster
STOPSIGNAL SIGTERM

# Force our preferred user
ARG user=elfie
RUN groupadd -g 568 $user && useradd -d /home/elfie --create-home --uid 568 --gid 568 --shell /bin/bash $user
USER 568

WORKDIR /config
WORKDIR /app

COPY --from=cloner /source/requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY --from=cloner /source/. .

# Debugging
COPY apps/kapowarr/dev/getcomics.py ./backend/implementations/getcomics.py

EXPOSE 5656

CMD [ "python3", "/app/Kapowarr.py", "--DatabaseFolder", "/config" ]
