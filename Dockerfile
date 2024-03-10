FROM alpine:3
LABEL maintainer="maximilian@schmailzl.net"

RUN apk add --no-cache bash nut msmtp jq sudo tzdata && \
	mkdir -p /var/run/nut && \
	chown nut:nut /var/run/nut && \
	echo "nut ALL=NOPASSWD:/sbin/poweroff,/sbin/reboot" >> /etc/sudoers && \
	echo "Set disable_coredump false" >> /etc/sudo.conf

COPY entrypoint.sh notification.sh /
COPY email_messages.json /etc/nut

EXPOSE 3493

ENV UPS_NAME="ups" UPS_DESCRIPTION="UPS" UPS_DRIVER="usbhid-ups" UPS_PORT="auto" API_USER="upsmon" API_ADDRESS="0.0.0.0" API_PORT="3493"
ENV SMTP_PORT="587" SMTP_AUTH="on" SMTP_TLS="on" SMTP_STARTTLS="on" SMTP_CERTCHECK="on"

ENTRYPOINT ["/entrypoint.sh"]
