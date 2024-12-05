FROM alpine:3.21.0

RUN apk --update add \
  ca-certificates \
  bash \
  jq \
  npm \
  git \
  openssh

RUN npm install -g semver

# can't `git pull` unless we set these
RUN git config --global user.email "git@localhost" && \
    git config --global user.name "git"

ADD apps/concourse-git-semver-tag-resource/assets/ /opt/resource/
RUN chmod +x /opt/resource/*

