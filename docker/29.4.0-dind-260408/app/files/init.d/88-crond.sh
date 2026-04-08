#!/usr/bin/env bash

__main() {
	_file="/data/entry/supervisor.d/crond.conf"
	mkdir -p ${_file%/*}
	cat >$_file <<EOF
[program:crond]
command=crond -f -L /dev/stdout
priority=999
autostart=true
autorestart=true
startretries=3
user=root
redirect_stderr=true
stdout_logfile=/data/entry/logs/crond.log
stdout_logfile_maxbytes=50MB
stdout_logfile_backups=10
environment=TERM="xterm"

EOF

}

__main
