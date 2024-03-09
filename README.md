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

### Environment variables

If not provided externally by bind mount, the configuration files are generated automatically using the following environment variables.\
Additionally, you can use any directive from `uspmon.conf` as an environment variable ([Documentation](https://networkupstools.org/docs/man/upsmon.conf.html)).

* `UPS_NAME` - Name of the UPS (default: `ups`)

* `UPS_DESC` - Short description of the UPS (default: `UPS`)

* `UPS_DRIVER` - The driver to use for the UPS (default: `usbhid-ups`)

* `UPS_PORT` - The serial port where the UPS is connected (default: `auto`)

* `API_ADDRESS` - The address used by upsd (default: `0.0.0.0`)

* `API_PORT` - The port used by upsd (default: `3493`)

* `API_USER` - The username for upsd (default: `upsmon`)

* `API_PASSWORD` - The username for upsd (default: random)

* `ADMIN_PASSWORD` - The username for the upsd admin user (default: random)



### Docker Run

A sample docker run command could look like this:

```sh
docker run -d \
    --name nut-upsd \
    --device /dev/bus/usb/xxx/yyy
    -p 3493:3493 \
    -e UPS_DESC="My UPS" \
    -e POLLFREQ=10 \
    -e SHUTDOWNCMD="shutdown -h now" \
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
      - "/dev/bus/usb/xxx/yyy:/dev/bus/usb/xxx/yyy"
    ports:
      - "3493:3493"
    environment:
      UPS_DESC: "My UPS"
      POLLFREQ: 10
      SHUTDOWNCMD: "shutdown -h now"
```
