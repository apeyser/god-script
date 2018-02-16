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

echo "Me: $0"
echo "Args: $*"
echo "Bash: $BASH"

echo "Real uid: $(id -u -r)"
echo "Effective uid: $(id -u)"

echo "I am: $(whoami)"
echo

echo Env:
/usr/bin/env

echo "Return some stuff, hit ctrl-d to end"
sed -re 's/^/Hi: /g'

echo "Done"
[[ $1 != error ]] || exit 5
