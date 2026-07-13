FROM docker:29.6.1-dind

LABEL hub_docker="https://hub.docker.com/_/docker"
LABEL maintainer="https://yuque.com/lwmacct"
LABEL document="https://yuque.com/lwmacct/docker/buildx"

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG TASK_VERSION=3.52.0

USER root

RUN set -eux; \
    echo "安装常用软件"; \
    apk add --no-cache \
        busybox-extras openssh-server supervisor tini bash jq bc curl wget rsync vim sudo tzdata socat iproute2 tmux skopeo perl-utils \
        findutils coreutils procps tar grep sed gawk dcron tzdata \
        nginx nginx-mod-stream nginx-mod-http-lua lua-resty-http;

RUN set -eux; \
    echo "taskfile"; \
    case "${TARGETARCH}" in \
        amd64 | arm64) ;; \
        *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    _task_archive="/tmp/task_linux_${TARGETARCH}.tar.gz"; \
    wget -O "${_task_archive}" "https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_${TARGETARCH}.tar.gz"; \
    tar -xzf "${_task_archive}" -C /usr/local/bin task; \
    chmod +x /usr/local/bin/task; \
    rm -f "${_task_archive}"; \
    task --version;

RUN set -eux; \
    rm -rf /etc/cron.d/; \
    ln -sfn /data/entry/cron.d/ /etc/cron.d; \
    ln -sfn /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    ln -sfn /bin/bash /bin/sh; \
    ln -sfn /data/entry/sshd /root/.ssh; \
    mkdir -p /etc/supervisor.d; \
    cat /etc/supervisord.conf > /etc/supervisord.conf.bak; \
    chmod -x /usr/sbin/zfs; \
    cp -af /etc/ssh /etc/ssh.bak; \
    ssh-keygen -A; \
    echo;


ENV TZ=Asia/Shanghai
ENV PYTHONDONTWRITEBYTECODE=1
ENV TASK_REMOTE_DIR=/root/.cache/taskfile
ENV TASK_X_REMOTE_TASKFILES=1
ENV NGINX_CONFIG_FILE=/data/deploy/config/nginx.conf
ENV REDIS_CONFIG_FILE=/data/deploy/config/redis.conf

COPY containers/latest/app/ /app/
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["bash", "/app/.entry.sh"]

LABEL org.opencontainers.image.source=https://github.com/lwmacct/250210-cr-docker
LABEL org.opencontainers.image.description="lwmacct"
LABEL org.opencontainers.image.licenses=MIT
