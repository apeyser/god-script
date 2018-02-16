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

##############
# make sure we get the right commands
# functions are early in command lookup
# after aliases
#

export PATH=/usr/bin:/usr/sbin:/bin

echo() {
    builtin echo "$@"
}

env() {
    command /usr/bin/env "$@"
}

sed() {
    command /usr/bin/sed "$@"
}

id() {
    command /usr/bin/id "$@"
}

whoami() {
    command /usr/bin/whoami "$@"
}

############
# and the real script
#

echo "Me: $0"
echo "Args: $*"
echo "Bash: $BASH"

echo "Real uid: $(id -u -r)"
echo "Effective uid: $(id -u)"

echo "I am: $(whoami)"
echo

echo Env:
env

echo "Return some stuff, hit ctrl-d to end"
sed -re 's/^/Hi: /g'

echo "Done"
[[ $1 != error ]] || exit 5
