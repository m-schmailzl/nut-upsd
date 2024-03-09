# Network UPS Tools server

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/schmailzl/nut-upsd)
![GitHub issues](https://img.shields.io/github/issues-raw/m-schmailzl/nut-upsd)
![Docker Image Size (amd64)](https://img.shields.io/docker/image-size/schmailzl/nut-upsd)
![Docker Pulls](https://img.shields.io/docker/pulls/schmailzl/nut-upsd)
![Docker Stars](https://img.shields.io/docker/stars/schmailzl/nut-upsd)

This image provides a complete UPS monitoring service (USB driver only).\
This is a fork of [sudo-bot/nut-upsd](https://github.com/sudo-bot/nut-upsd).\
I added a lot of additional configuration options and implemented email notifications.


## Usage

You can mount your own `/etc/nut/ups.conf`, `/etc/nut/upsd.conf`, `/etc/nut/upsd.users` and `/etc/nut/upsmon.conf`.\
You need to mount these files as read-only, otherwise they are overwritten.

### General configuration

If not provided externally by bind mount, the configuration files are generated automatically using the following environment variables:

* `UPS_NAME` - Name of the UPS (default: `ups`)

* `UPS_DESCRIPTION` - Short description of the UPS (default: `UPS`)

* `UPS_DRIVER` - The driver to use for the UPS (default: `usbhid-ups`)

* `UPS_PORT` - The serial port where the UPS is connected (default: `auto`)

* `API_ADDRESS` - The address used by upsd (default: `0.0.0.0`)

* `API_PORT` - The port used by upsd (default: `3493`)

* `API_USER` - The username for upsd (default: `upsmon`)

* `API_PASSWORD` - The username for upsd (default: random)

* `ADMIN_PASSWORD` - The username for the upsd admin user (default: random)


### upsmon.conf

You can set any directive from `uspmon.conf` as an environment variable ([Documentation](https://networkupstools.org/docs/man/upsmon.conf.html)) e.g. `POLLFREQ` or `SHUTDOWNCMD`.


### Email notifications

You have to configure at least these options to enable email notifications:

* `NOTIFICATION_EMAIL` - Notification emails are sent to this email adress.

* `NOTIFICATION_FROM` - Email address from which the emails are sent

* `NOTIFICATION_FROM_NAME` - The display name of the email sender (default: `$UPS_DESCRIPTION`)

By default, you get notifications for all upsmon events.\
You can disable emails for a certain event type by setting the environment variable `NOTIFY_<type>` to `0`, e.g. `NOTIFY_LOWBATT=0` (types under 'NOTIFYMSG' in [Documentation](https://networkupstools.org/docs/man/upsmon.conf.html)).

The file `/etc/nut/email_messages.json` contains the subjects and messages of the notification emails.\
You can provide your own messages by mounting your own file.

You have to set your smtp server by either providing `/etc/msmtprc` (read-only) or using the following environment variables:

* `SMTP_HOST` - Hostname of the SMTP server

* `SMTP_PORT` - Port of the SMTP server (default: `587`)

* `SMTP_AUTH` - Enable/disable user authentication (`on/off`, default: `on`)

* `SMTP_USER` - Username/email for authentication (default: `$NOTIFICATION_FROM`)

* `SMTP_PASSWORD` - Password for authentication

* `SMTP_TLS` - Enable/disable TLS (`on/off`, default: `on`)

* `SMTP_STARTTLS` - Enable/disable STARTTLS (`on/off`, default: `on`)

* `SMTP_CERTCHECK` - Enable/disable certificate verification (`on/off`, default: `on`)


### Docker Run

A sample docker run command could look like this:

```sh
docker run -d \
    --name nut-upsd \
    --device /dev/bus/usb/xxx/yyy
    -p 3493:3493 \
    -e UPS_DESCRIPTION="My UPS" \
    -e POLLFREQ=10 \
    -e NOTIFY_NOCOMM=0 \
    -e NOTIFICATION_EMAIL="admin@example.com" \
    -e NOTIFICATION_FROM="noreply@example.com" \
    -e SMTP_HOST="smtp.example.com" \
    -e SMTP_PASSWORD="xxxx" \
    schmailzl/nut-upsd
```


### Docker Compose

A sample docker-compose.yml could look like this:

```yaml
version: '3'
services:
  nut:
    image: schmailzl/nut-upsd
    devices:
      - "/dev/bus/usb/xxx/yyy"
    ports:
      - "3493:3493"
    environment:
      UPS_DESCRIPTION: "My UPS"
      POLLFREQ: 10
      NOTIFY_NOCOMM: 0
      NOTIFICATION_EMAIL: admin@example.com
      NOTIFICATION_FROM: noreply@example.com
      SMTP_HOST: smtp.example.com
      SMTP_PASSWORD: xxxx
```
