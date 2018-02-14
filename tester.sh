echo "Me: $0"
echo "Args: $*"

echo "Real uid: $(id -u -r)"
echo "Effecutive uid $(id -u)"

whoami
echo

echo Env:
env

echo "Return some stuff, hit ctrl-d to end"
cat  | sed -re 's/^/Hi: /g'

[[ $1 != error ]] || exit 5
