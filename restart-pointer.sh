#!/bin/bash

#sudo modprobe -r hid_rmi
#sudo modprobe hid_rmi

user() {
    if PTR=$(xinput list | grep -iPo 'touchpad.*id=\K\d+'); then
        xinput --disable $PTR
        xinput --enable $PTR
    fi

    echo -n 'reconnect'
}

root() {
    tee /sys/bus/serio/devices/serio1/drvctl >/dev/null
    modprobe -r rmi_smbus
    modprobe rmi_smbus
}

sudo-cmd() {
    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY "$@"
}

exec-func() {
    func=$1
    sudo-cmd /bin/bash -c "$(declare -f $func); $func"
}

user | exec-func root
