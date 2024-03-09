FROM alpine:3
LABEL maintainer="maximilian@schmailzl.net"

RUN apk add --no-cache bash nut msmtp jq && \
	mkdir -p /var/run/nut && \
	chown nut:nut /var/run/nut

COPY entrypoint.sh notification.sh /
COPY email_messages.json /etc/nut

EXPOSE 3493

ENV UPS_NAME="ups" UPS_DESCRIPTION="UPS" UPS_DRIVER="usbhid-ups" UPS_PORT="auto" API_USER="upsmon" API_ADDRESS="0.0.0.0" API_PORT="3493"

ENTRYPOINT ["/entrypoint.sh"]
