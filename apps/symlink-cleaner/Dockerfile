# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone https://github.com/bsm-elf/symlink-cleaner.git /source

FROM python:3.9-slim

WORKDIR /app

COPY --from=cloner /source/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --from=cloner /source/symlink_cleaner.py .

RUN mkdir -p /app/config/logs \
    && chown -R 568:568 /app/config \
    && chmod -R u+rw /app/config

USER 568
EXPOSE 5000
CMD ["python", "symlink_cleaner.py"]