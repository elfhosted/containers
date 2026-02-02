FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/qwertyuiop8899/toast-translator.git /source

FROM python:3.10-slim-buster
WORKDIR /app
COPY --from=cloner /source/. /app
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080
CMD ["python", "main.py"]