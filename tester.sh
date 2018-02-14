echo "Me: $0"
echo "Args: $*"
id -u -r
id -u

whoami

echo Env:
env

[[ $1 != error ]] || exit 5
