#!/bin/bash

UPSMON_ENV=(
	DEADTIME FINALDELAY HOSTSYNC MINSUPPLIES MONITOR 
	NOCOMMWARNTIME POLLFAIL_LOG_THROTTLE_MAX POLLFREQ 
	POLLFREQALERT OFFDURATION RBWARNTIME RUN_AS_USER 
	SHUTDOWNEXIT CERTIDENT CERTHOST CERTVERIFY FORCESSL DEBUG_MIN
)

UPSMON_ENV_QUOTES=(
	NOTIFYCMD POWERDOWNFLAG SHUTDOWNCMD CERTPATH
)

NOTIFY_TYPES=(
	ONLINE ONBATT LOWBATT FSD COMMOK COMMBAD SHUTDOWN REPLBATT 
	NOCOMM NOPARENT CAL OFF NOTOFF BYPASS NOTBYPASS
)


if [ -z "$API_PASSWORD" ]; then
	export API_PASSWORD=$(dd if=/dev/urandom bs=18 count=1 2>/dev/null | base64)
	echo "Generated API_PASSWORD: $API_PASSWORD"
fi

if [ -z "$ADMIN_PASSWORD" ]; then
	export ADMIN_PASSWORD=$(dd if=/dev/urandom bs=18 count=1 2>/dev/null | base64)
	echo "Generated ADMIN_PASSWORD: $ADMIN_PASSWORD"
fi

if [ -z "$MONITOR" ]; then
	export MONITOR="$UPS_NAME@localhost 1 $API_USER $API_PASSWORD master"
fi

if [ -z "$NOTIFYCMD" ] && [ -n "$NOTIFICATION_EMAIL" ]; then
	export NOTIFYCMD="/notification.sh"
fi

if [ -z "$SHUTDOWNCMD" ]; then
	export SHUTDOWNCMD="echo 'SHUTDOWNCMD has not been set!'"
fi

if [ -z "$SMTP_USER" ]; then
	export SMTP_USER="$NOTIFICATION_FROM"
fi

if [ -z "$NOTIFICATION_FROM_NAME" ]; then
	export NOTIFICATION_FROM_NAME="$UPS_DESCRIPTION"
fi


overrides=""
if [ -n "$LOWBATT_PERCENT" ] || [ -n "$LOWBATT_RUNTIME" ]; then
	printf -v overrides "ignorelb\n"

	if [ -n "$LOWBATT_PERCENT" ]; then
		printf -v overrides "$overrides\toverride.battery.charge.low = $LOWBATT_PERCENT\n"
	fi

	if [ -n "$LOWBATT_RUNTIME" ]; then
		printf -v overrides "$overrides\toverride.battery.runtime.low = $LOWBATT_RUNTIME\n"
	fi
fi

if [ ! -e /etc/nut/ups.conf ]; then
cat >/etc/nut/ups.conf <<EOF
[$UPS_NAME]
	desc = "$UPS_DESCRIPTION"
	driver = $UPS_DRIVER
	port = $UPS_PORT
	$overrides
EOF
else
    echo "Skipped generation of ups.conf (user config is mounted)."
fi

if [ ! -e /etc/nut/upsd.conf ]; then
cat >/etc/nut/upsd.conf <<EOF
LISTEN $API_ADDRESS $API_PORT
EOF
else
    echo "Skipped generation of upsd.conf (user config is mounted)."
fi

if [ ! -e /etc/nut/upsd.users ]; then
cat >/etc/nut/upsd.users <<EOF
[admin]
	password = $ADMIN_PASSWORD
	actions = set
	actions = fsd
	instcmds = all

[$API_USER]
	password = $API_PASSWORD
	upsmon master
EOF
else
    echo "Skipped generation of upsd.users (user config is mounted)."
fi

if [ ! -e /etc/nut/upsmon.conf ]; then
	echo "# upsmon configuration generated by schmailzl/nut-upsd" > /etc/nut/upsmon.conf

	for env in "${UPSMON_ENV[@]}"; do
		if [ -n "${!env}" ]; then
			echo "$env ${!env}" >> /etc/nut/upsmon.conf
		fi
	done

	for env in "${UPSMON_ENV_QUOTES[@]}"; do
		if [ -n "${!env}" ]; then
			echo "$env \"${!env}\"" >> /etc/nut/upsmon.conf
		fi
	done

	echo >> /etc/nut/upsmon.conf

	for type in "${NOTIFY_TYPES[@]}"; do
		var="NOTIFY_$type"
		if [ -n "$NOTIFYCMD" ] && [ "${!var}" != "0" ]; then
			echo "NOTIFYFLAG $type SYSLOG+EXEC" >> /etc/nut/upsmon.conf
		else
			echo "NOTIFYFLAG $type SYSLOG" >> /etc/nut/upsmon.conf
		fi
	done

	echo >> /etc/nut/upsmon.conf

	for type in "${NOTIFY_TYPES[@]}"; do
		var="NOTIFYMSG_$type"
		if [ -n "${!var}" ]; then
			echo "NOTIFYMSG $type \"${!var}\"" >> /etc/nut/upsmon.conf
		fi
	done
else
    echo "Skipped generation of upsmon.conf (user config is mounted)."
fi

if [ ! -e /etc/msmtprc ]; then
cat >/etc/msmtprc <<EOF
defaults
tls $SMTP_TLS
tls_starttls $SMTP_STARTTLS
tls_certcheck $SMTP_CERTCHECK
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host $SMTP_HOST
port $SMTP_PORT
user $SMTP_USER
password $SMTP_PASSWORD
auth $SMTP_AUTH
from $NOTIFICATION_FROM
logfile -
EOF
fi


if [ ! -d /dev/bus/usb ]; then
	echo "There is no USB device mapped to the container!"
	exit 1
fi

chgrp -R nut /etc/nut /dev/bus/usb

/usr/sbin/upsdrvctl start
/usr/sbin/upsd
exec /usr/sbin/upsmon -D
