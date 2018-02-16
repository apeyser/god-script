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
