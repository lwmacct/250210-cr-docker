#!/usr/bin/env bash

__supervisor() {
  _file="/etc/supervisor.d/nginx.conf"
  mkdir -p "${_file%/*}"
  cat >"$_file" <<EOF
[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
priority=999
autostart=true
autorestart=true
startretries=3
user=root
redirect_stderr=true
stdout_logfile=/data/entry/logs/nginx.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=TERM="xterm"
EOF
}

__main() {
  _config="/etc/nginx/nginx.conf"
  _file="/etc/supervisor.d/nginx.conf"

  if [[ ! -L "$_config" ]]; then
    rm -f "$_file"
    return
  fi

  __supervisor
}

__main
