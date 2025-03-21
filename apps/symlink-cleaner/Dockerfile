# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/bsm-elf/symlink-cleaner.git /source

FROM python:3.9-slim
WORKDIR /app
COPY --from=cloner /source/requirements.txt .
RUN pip install -r requirements.txt
COPY --from=cloner /source/. .
EXPOSE 5000
CMD ["python", "symlink_cleaner.py", "--config", "/app/config.json"]