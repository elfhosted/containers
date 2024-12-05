FROM alpine:3.21.0

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Stark & Wayne <beahero@starkandwayne.com>" \
      summary="Concourse Slack Notifications Resource" \
      version=$VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/cloudfoundry-community/slack-notification-resource.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

RUN apk add --no-cache curl bash jq gettext-dev

COPY apps/concourse-slack-notification-resource/check /opt/resource/check
COPY apps/concourse-slack-notification-resource/in    /opt/resource/in
COPY apps/concourse-slack-notification-resource/out   /opt/resource/out

RUN chmod +x /opt/resource/out /opt/resource/in /opt/resource/check

ADD apps/concourse-slack-notification-resource/test/ /opt/resource-tests/
RUN /opt/resource-tests/all.sh \
 && rm -rf /tmp/*
