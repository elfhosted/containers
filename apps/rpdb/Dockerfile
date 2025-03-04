FROM debian:bullseye-slim

LABEL maintaner="jaruba"
LABEL description="Docker container to run RPDB Folders"

ARG version=0.2.7

RUN apt-get update && \
    apt-get install -y unzip && \
    apt-get install -y wget

WORKDIR /app

RUN wget https://github.com/RatingPosterDB/rpdb-folders/releases/latest/download/linux-rpdb-folders.zip && \
    mkdir -p ./rpdb-folders && \
    unzip linux-rpdb-folders.zip -d ./rpdb-folders && \
    rm ./linux-rpdb-folders.zip && \
    mkdir -p /rpdb/config && \
    mkdir -p /rpdb/mounts && \
    chmod +x ./rpdb-folders/rpdb-folders

WORKDIR /app/rpdb-folders

VOLUME ["/rpdb/config"]
VOLUME ["/rpdb/mounts"]

EXPOSE 8750
CMD ["./rpdb-folders", "--no-browser"]