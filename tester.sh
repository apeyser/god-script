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
