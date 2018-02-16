#!/bin/bash

####################
# Fail out on error
set -e

####################
# make sure we get
# the right command

export PATH=/usr/bin:/usr/sbin:/bin

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

######
# script for user
# we drop privileges before this
user() {
    if PTR=$(xinput list | grep -iPo 'touchpad.*id=\K\d+'); then
        xinput --disable $PTR
        xinput --enable $PTR
    fi
}

#######
# script for root
# we have privileges here
root() {
    echo -n 'reconnect' >/sys/bus/serio/devices/serio1/drvctl
    modprobe -r rmi_smbus
    modprobe rmi_smbus
}

#######
# Function for dropping privileges
unsudo-func() {
    func=$1
    sudo -u \#$(id -u -r) \
         /usr/bin/bash -c "$(declare -f $func); $func"
}

######
# Script
# Call user code with no privileges,
# and root code with

unsudo-func user
root
