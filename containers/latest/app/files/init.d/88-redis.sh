#!/usr/bin/env bash

__supervisor() {
  _file="/etc/supervisor.d/redis.conf"
  mkdir -p "${_file%/*}"
  cat >"$_file" <<EOF
[program:redis]
command=/usr/bin/redis-server /etc/redis.conf --daemonize no
priority=999
autostart=true
autorestart=true
startretries=3
user=root
redirect_stderr=true
stdout_logfile=/data/entry/logs/redis.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=TERM="xterm"
EOF
}

__main() {
  _source="${REDIS_CONFIG_FILE:-/data/deploy/config/redis.conf}"
  _target="/etc/redis.conf"
  _file="/etc/supervisor.d/redis.conf"
  rm -f "$_file"

  if [[ ! -e "$_source" ]]; then
    return
  fi

  ln -sfn "$_source" "$_target"
  __supervisor
}

__main
