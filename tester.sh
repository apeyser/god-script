echo "Args: $*"
id -u -r
id -u

whoami
[[ $1 != error ]] || exit 5
