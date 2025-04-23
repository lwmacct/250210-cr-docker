#!/usr/bin/env bash
# shellcheck disable=SC2317
# document https://www.yuque.com/lwmacct/docker/buildx

__main() {
    {
        _sh_path=$(realpath "$(ps -p $$ -o args= 2>/dev/null | awk '{print $2}')") # 当前脚本路径
        _pro_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-2)}')               # 当前项目名
        _dir_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-1)}')               # 当前目录名
        _image="${_pro_name}:$_dir_name"
    }

    _dockerfile=$(
        # 双引号不转义
        cat <<"EOF"
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

LABEL org.opencontainers.image.source=$_ghcr_source
LABEL org.opencontainers.image.description="lwmacct"
LABEL org.opencontainers.image.licenses=MIT
EOF
    )
    {
        cd "$(dirname "$_sh_path")" || exit 1
        echo "$_dockerfile" >Dockerfile

        _ghcr_source=$(sed 's|git@github.com:|https://github.com/|' ../.git/config | grep url | sed 's|.git$||' | awk '{print $NF}')
        _ghcr_source=${_ghcr_source:-"https://github.com/lwmacct/250210-cr-buildx"}
        sed -i "s|\$_ghcr_source|$_ghcr_source|g" Dockerfile
    }

    {
        if command -v sponge >/dev/null 2>&1; then
            jq 'del(.credsStore)' ~/.docker/config.json | sponge ~/.docker/config.json
        else
            jq 'del(.credsStore)' ~/.docker/config.json >~/.docker/config.json.tmp && mv ~/.docker/config.json.tmp ~/.docker/config.json
        fi
    }
    {
        _registry="ghcr.io/lwmacct" # 托管平台, 如果是 docker.io 则可以只填写用户名
        _repository="$_registry/$_image"
        echo "image: $_repository"
        docker buildx build --builder default --platform linux/amd64 -t "$_repository" --network host --progress plain --load . && {
            _image_id=$(docker images "$_repository" --format "{{.ID}}")
            if false; then
                docker rm -f sss 2>/dev/null
                docker run -itd --name=sss \
                    --restart=always \
                    --network=host \
                    --privileged=false \
                    "$_image_id"
                docker exec -it sss bash
            fi
        }
        docker push "$_repository"

    }
}

__main

__help() {
    cat >/dev/null <<"EOF"
这里可以写一些备注

ghcr.io/lwmacct/250210-cr-docker:28.1.1-dind-2504230

EOF
}
