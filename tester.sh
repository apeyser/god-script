echo "Me: $0"
echo "Args: $*"

echo "Real uid: $(id -u -r)"
echo "Effecutive uid $(id -u)"

whoami
echo

echo Env:
env

[[ $1 != error ]] || exit 5
