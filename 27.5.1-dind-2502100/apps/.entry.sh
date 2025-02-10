#!/usr/bin/env bash
# Admin https://www.yuque.com/lwmacct

__supervisord() {
    cat >/etc/supervisord.conf <<EOF
[unix_http_server]
file=/run/supervisord.sock
chmod=0700
chown=nobody:nogroup

[supervisord]
user=root
nodaemon=true
logfile=/var/log/supervisord.log
logfile_maxbytes=5MB
logfile_backups=2
pidfile=/var/run/supervisord.pid

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///run/supervisord.sock
prompt=mysupervisor
history_file=~/.sc_history

[include]
files = /etc/supervisor.d/*.conf /data/entry/supervisor.d/*.conf
EOF
    exec supervisord -c /etc/supervisord.conf
}

# __supervisord

__main() {
    mkdir -p /data/entry/{,logs,script,cron.d,supervisor.d}
    {
        : # 初始化文件
        tar -vcpf - -C /apps/file . | (cd / && tar -xpf - --skip-old-files)
    } 2>&1 | tee /data/entry/logs/entry-tar.log

    {
        for _script in /data/entry/init.d/*.sh; do
            if [ -r "$_script" ]; then
                echo "Run $_script"
                timeout 30 bash "$_script"
            fi
        done
    } >/data/entry/logs/entry-source.log 2>&1
    __supervisord
    # exec sleep infinity
}

__main
