FROM docker:28.1.1-dind

LABEL maintainer="https://yuque.com/lwmacct"
LABEL document="https://yuque.com/lwmacct/docker/buildx"
ARG DEBIAN_FRONTEND=noninteractive
USER root

RUN set -eux; \
    echo "安装常用软件"; \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories; \
    apk add --no-cache \
        busybox-extras openssh-server supervisor tini bash jq bc curl wget rsync vim sudo tzdata socat iproute2 tmux skopeo \
        findutils coreutils procps tar grep sed gawk dcron tzdata;

RUN set -eux; \
    echo "taskfile"; \
    apk add --no-cache npm; \
    npm install -g @go-task/cli; \
    task --version; \
    apk del npm;

RUN set -eux; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    rm -rf /etc/cron.d/; \
    ln -sf /data/entry/cron.d/ /etc/cron.d; \
    ln -sf /bin/bash /bin/sh; \
    mkdir -p /etc/supervisor.d; \
    cat /etc/supervisord.conf > /etc/supervisord.conf.bak; \
    chmod -x /usr/sbin/zfs; \
    cp -af /etc/ssh /etc/ssh.bak; \
    ssh-keygen -A; \
    echo;

COPY apps/ /apps/
ENV TZ=Asia/Shanghai
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["bash", "/apps/.entry.sh"]

LABEL org.opencontainers.image.source=https://github.com/lwmacct/250210-cr-docker
LABEL org.opencontainers.image.description="lwmacct"
LABEL org.opencontainers.image.licenses=MIT
