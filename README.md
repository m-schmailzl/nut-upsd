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

```sh
docker run -d \
    --name nut-upsd \
    --publish 3493:3493 \
    --device /dev/bus/usb/xxx/yyy \
    --env SHUTDOWN_CMD="my-shutdown-command-from-container" \
    schmailzl/nut-upsd
```

## Auto configuration via environment variables

This image supports customization via environment variables.

### UPS_NAME

*Default value*: `ups`

The name of the UPS.

### UPS_DESC

*Default value*: `Eaton 5SC`

This allows you to set a brief description that upsd will provide to clients that ask for a list of connected equipment.

### UPS_DRIVER

*Default value*: `usbhid-ups`

This specifies which program will be monitoring this UPS.

### UPS_PORT

*Default value*: `auto`

This is the serial port where the UPS is connected.

### API_PORT

*Default value*: `3493`

This is the port used by upsd.

### API_ADDRESS

*Default value*: `0.0.0.0`

This is the address used by upsd.

### API_USER

*Default value*: `upsmon`

This is the username used for communication between upsmon and upsd processes.

### API_PASSWORD

*Default value*: `secret`

This is the password for the upsmon user.

### SHUTDOWN_CMD

*Default value*: `echo 'System shutdown is not configured!'`

This is the command upsmon will run when the system needs to be brought down. The command will be run from inside the container.
