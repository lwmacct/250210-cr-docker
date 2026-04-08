#!/usr/bin/env bash
# author https://github.com/lwmacct

__release() {
	: # 释放资源

	{
		{
			: # 初始化文件
			mkdir -p /data/entry/{,logs,scripts,cron.d,supervisor.d}
			tar -vcpf - -C /app/free . | (cd / && tar -xpf - --skip-old-files)
		}

		{
			echo "start init"
			for _script in /data/entry/init.d/*.sh; do
				if [ -r "$_script" ]; then
					echo "Run $_script"
					timeout 15 bash "$_script"
				fi
			done
		}

	} 2>&1 | tee -a /var/log/entry.log
}

__supervisord() {

	cat >/etc/supervisord.conf <<EOF
[unix_http_server]
file=/run/supervisord.sock
chmod=0700
chown=nobody:nogroup

[supervisord]
user=root
nodaemon=true
pidfile=/var/run/supervisord.pid
logfile=/var/log/supervisord.log
logfile_maxbytes=100MB
logfile_backups=2

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///run/supervisord.sock
prompt=mysupervisor
history_file=~/.sc_history

[include]
files = /etc/supervisor/conf.d/*.conf /data/entry/supervisor.d/*.conf /app/files/supervisor.d/*.conf
EOF
}

__main() {

	__release
	__supervisord
	exec supervisord

}

__main
