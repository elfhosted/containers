# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/Dictionarry-Hub/profilarr.git /source

FROM python:3.9
WORKDIR /app
COPY --from=cloner /source/backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --from=cloner /source/backend/. .
CMD ["python", "-m", "app.main"]