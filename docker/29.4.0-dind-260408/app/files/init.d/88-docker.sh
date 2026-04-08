#!/usr/bin/env bash

__main() {
	_file="/data/entry/supervisor.d/docker.conf"
	mkdir -p ${_file%/*}
	cat >$_file <<EOF
[program:docker]
command=/usr/local/bin/dockerd-entrypoint.sh --exec-opt native.cgroupdriver=cgroupfs --storage-driver=overlay2 --dns=119.29.29.29 --dns=114.114.114.114 --log-driver=json-file --log-opt max-size=1m --log-opt max-file=1
priority=999
autostart=true
autorestart=true
startretries=3
user=root
redirect_stderr=true
stdout_logfile=/data/entry/logs/docker.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=TERM="xterm"
EOF

}

__main
