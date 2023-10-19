ARG VERSION
FROM hrfee/jfa-go:${VERSION} as upstream
FROM golang:latest

COPY --from=upstream /opt/jfa-go /opt/jfa-go

EXPOSE 8056
EXPOSE 8057

RUN addgroup elfie --gid 568 && \
    adduser --uid 568 --gid 568 --home /config elfie 

USER 568

CMD [ "/opt/jfa-go/jfa-go", "-data", "/config" ]
