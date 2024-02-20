# Get the elfhosted code
FROM alpine:latest as cloner
ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION --depth 1 https://github.com/mhdzumair/MediaFusion.git /source

FROM python:3.11-slim-bullseye

WORKDIR /mediafusion

# Install dependencies
RUN pip install --upgrade pip && \
    pip install pipenv && \
    apt-get update && \
    apt-get install -y git

RUN \
    adduser elfie \
        --uid 568 \
        --group \
        --system \
        --disabled-password

USER 568
COPY --from=cloner /source/Pipfile /source/Pipfile.lock ./


RUN pipenv install --deploy --ignore-pipfile

ARG GIT_REV="dev"
ENV GIT_REV=$GIT_REV

# Copy the source code
COPY --from=cloner /source .

# Expose the port
EXPOSE 8000

CMD ["pipenv", "run", "gunicorn", "api.main:app", "-w", "4", "-k", "--system", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000", "--timeout", "120"]