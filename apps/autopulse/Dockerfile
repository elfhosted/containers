# Get upstream code
FROM alpine:latest as cloner
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN git clone -b $VERSION  https://github.com/dan-online/autopulse.git /source

# Install cargo-chef for a base step
FROM clux/muslrust:stable AS chef
USER root
RUN cargo install cargo-chef
WORKDIR /app

# Plan out the build
FROM chef AS planner
COPY --from=cloner /source/. .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json recipe.json

# Database support: postgres, sqlite
ARG ENABLED_FEATURES="sqlite"
ARG TARGET="x86_64-unknown-linux-musl"

RUN cargo chef cook --release --target ${TARGET} --recipe-path recipe.json --features ${ENABLED_FEATURES}

# Compile dependencies
COPY --from=cloner /source/Cargo.toml /source/Cargo.lock ./

# Copy source and build
COPY --from=cloner /source/src src
COPY --from=cloner /source/migrations migrations
COPY --from=cloner /source/README.md README.md

RUN cargo build --release --target ${TARGET} --no-default-features --features ${ENABLED_FEATURES}

RUN cp target/${TARGET}/release/autopulse /tmp/autopulse

FROM --platform=$TARGETPLATFORM alpine AS runtime

WORKDIR /app

COPY --from=builder /tmp/autopulse /usr/local/bin/

CMD ["/usr/local/bin/autopulse"]