#!/usr/bin/env bash

__main() {
    _file="/data/entry/supervisor.d/docker.conf"
    mkdir -p ${_file%/*}
    cat >$_file <<EOF
[program:docker]
command=/usr/local/bin/dockerd-entrypoint.sh --exec-opt native.cgroupdriver=cgroupfs --storage-driver=overlay2 --dns=223.5.5.5 --dns=119.29.29.29 --log-driver=json-file --log-opt max-size=1m --log-opt max-file=1
priority=999
autostart=true
autorestart=true
stdout_logfile=/data/entry/logs/docker_out.log
stderr_logfile=/data/entry/logs/docker_err.log
EOF

}

__main
