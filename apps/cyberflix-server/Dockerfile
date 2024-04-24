# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone --depth 1 https://github.com/marcojoao/cyberflix-server.git /source
FROM python:3.11

WORKDIR /app

COPY --from=cloner /source/requirements.txt .

RUN pip install -r requirements.txt

COPY --from=cloner /source .

EXPOSE 8000

CMD ["gunicorn", "run:app", "--threads 4", "--worker-class", "uvicorn.workers.UvicornWorker","--bind", "0.0.0.0:8000" ]