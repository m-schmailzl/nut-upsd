FROM debian:13
LABEL maintainer="maximilian@schmailzl.net"

RUN apt-get update && apt-get install -y msmtp jq tzdata systemd nut nut-snmp snmp curl && \
	rm -rf /var/lib/apt/lists/* && \
	cd /etc/nut && \
	echo "MODE=netserver" >> nut.conf && \
	rm ups.conf upsd.conf upsd.users upsmon.conf

COPY entrypoint.sh notification.sh /
COPY email_messages.json /etc/nut

EXPOSE 3493

ENV UPS_NAME="ups" UPS_DESCRIPTION="UPS" UPS_DRIVER="usbhid-ups" UPS_PORT="auto" UPS_COMMUNITY="public" API_USER="upsmon" API_ADDRESS="0.0.0.0" API_PORT="3493"
ENV RUN_AS_USER="nut" SHUTDOWNEXIT="no" SMTP_PORT="587" SMTP_AUTH="on" SMTP_TLS="on" SMTP_STARTTLS="on" SMTP_CERTCHECK="on"

ENTRYPOINT ["/entrypoint.sh"]
