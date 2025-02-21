#!/usr/bin/env bash

__sshd_config() {
    cat <<EOF >/etc/ssh/sshd_config
Port 22
PermitRootLogin yes
PasswordAuthentication yes

AuthorizedKeysFile      .ssh/authorized_keys
AllowTcpForwarding no
GatewayPorts no
X11Forwarding no
Subsystem       sftp    internal-sftp
EOF
}

__supervisor() {
    _file="/data/entry/supervisor.d/sshd.conf"
    mkdir -p ${_file%/*}
    cat >$_file <<EOF
[program:sshd]
command=/usr/sbin/sshd -D
priority=999
autostart=true
autorestart=true
stderr_logfile=/data/entry/logs/sshd_err.log
stdout_logfile=/data/entry/logs/sshd_out.log

EOF
}
__main() {
    ssh-keygen -A
    _file_pwd="/data/entry/sshd/password"
    mkdir -p ${_file_pwd%/*}
    _password=$(cat "$_file_pwd" 2>/dev/null)
    if [[ -z "$_password" ]]; then
        _password=$(cat /proc/sys/kernel/random/uuid)
        echo "$_password" >$_file_pwd
    fi

    echo "root:$_password" | chpasswd
    __sshd_config
    __supervisor

}

__main
