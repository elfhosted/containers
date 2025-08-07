# Get the upstream code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/Drakonis96/plexytrack.git  /source

FROM python:3.11-slim

WORKDIR /app

COPY --from=cloner /source/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY --from=cloner /source/. .

RUN mkdir /config/state && \
    ln -s /config/* /

VOLUME /config

CMD ["python", "app.py"]
