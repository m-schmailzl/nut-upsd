FROM alpine:3
LABEL maintainer="maximilian@schmailzl.net"

RUN apk add --no-cache bash nut msmtp

COPY entrypoint.sh /usr/local/bin/

WORKDIR /

EXPOSE 3493

ENV UPS_NAME="ups" UPS_DESC="UPS" UPS_DRIVER="usbhid-ups" UPS_PORT="auto" SHUTDOWN_CMD="echo 'System shutdown not configured!'"

ENTRYPOINT ["entrypoint.sh"]
