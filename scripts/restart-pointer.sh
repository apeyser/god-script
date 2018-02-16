##################################################
#  Copyright 2018 Alexander Peyser
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
####################################################

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
