#!/bin/bash

set -e

#sudo modprobe -r hid_rmi
#sudo modprobe hid_rmi

xinput() {
    command /usr/bin/xinput "$@"
}

grep() {
    command /usr/bin/grep "$@"
}

modprobe() {
    command /usr/sbin/modprobe "$@"
}

echo() {
    builtin echo "$@"
}

sudo() {
    command /usr/bin/sudo "$@"
}

user() {
    if PTR=$(xinput list | grep -iPo 'touchpad.*id=\K\d+'); then
        xinput --disable $PTR
        xinput --enable $PTR
    fi
}

root() {
    echo -n 'reconnect' >/sys/bus/serio/devices/serio1/drvctl
    modprobe -r rmi_smbus
    modprobe rmi_smbus
}

unsudo-func() {
    func=$1
    sudo -u \#$(id -u -r) \
         /usr/bin/bash -c "$(declare -f $func); $func"
}

export PATH=/usr/bin:/usr/sbin:/bin
unsudo-func user
root
