#!/bin/sh
# docker entrypoint script

echo "[i] Initial Container"

# allow the container to be started with `--user` or `-u`
# if [ "$1" = 'app-name' -a "$(id -u)" = '0' ]; then
# 	echo "[i] Restart container with user: user-name"
# 	echo ""
# 	exec gosu user-name "$0" "$@"
# fi

echo "[i] Start Application"
exec "$@"
