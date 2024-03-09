FROM alpine:3
LABEL maintainer="maximilian@schmailzl.net"

RUN apk add --no-cache bash nut msmtp

COPY entrypoint.sh /

WORKDIR /

EXPOSE 3493

ENV UPS_NAME="ups" UPS_DESC="UPS" UPS_DRIVER="usbhid-ups" UPS_PORT="auto" API_USER="upsmon" API_ADDRESS="0.0.0.0" API_PORT="3493"

ENTRYPOINT ["entrypoint.sh"]
