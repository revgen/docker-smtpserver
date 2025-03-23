FROM alpine:3.20.6

ARG NAME="rev9en/smtpserver"
ARG VERSION="0.1.2"

LABEL version="${VERSION}"
LABEL description="Simple smtp relay server"
LABEL created="2025-01-13"
LABEL maintainer="Evgen Rusakov"
LABEL url.docker="https://hub.docker.com/r/rev9en/smtpserver"
LABEL url.source="https://github.com/revgen/docker-smtpserver"

RUN \
    apk add --no-cache postfix cyrus-sasl cyrus-sasl-login cyrus-sasl-crammd5 && \
    postconf -ev 'inet_interfaces = all' && \
    postconf -ev 'mydestination = localhost' && \
    postconf -ev 'myorigin = $mydomain' && \
    postconf -ev 'smtp_host_lookup = native,dns' && \
    postconf -ev 'maillog_file = /dev/stdout' && \
    newaliases

COPY entrypoint.sh /

EXPOSE 25
ENTRYPOINT [ "/entrypoint.sh" ]