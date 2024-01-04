FROM alpine:3.18

RUN apk --no-cache --update add sudo syslog-ng openssh curl \
    && rm -rf /var/cache/apk/*

COPY files/ /

WORKDIR /root

EXPOSE 22

ENTRYPOINT [ "/usr/local/bin/container-entrypoint.sh" ]


