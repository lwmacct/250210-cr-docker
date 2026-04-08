#!/usr/bin/env bash
# shellcheck disable=SC2317
# document https://www.yuque.com/lwmacct/docker/buildx

__main() {
	{
		_sh_path=$(realpath "$(ps -p $$ -o args= 2>/dev/null | awk '{print $2}')")    # 当前脚本路径
		_dir_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-1)}')                  # 当前目录名
		_pro_name=$(git remote get-url origin | head -n1 | xargs -r basename -s .git) # 当前仓库名
		_image="${_pro_name}:$_dir_name"
	}

	_dockerfile=$(
		cat <<"EOF"
FROM docker:28.5.2-dind

LABEL hub_docker="https://hub.docker.com/_/docker"
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

COPY app/ /app/
ENV TZ=Asia/Shanghai
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["bash", "/app/.entry.sh"]

LABEL org.opencontainers.image.source=$_ghcr_source
LABEL org.opencontainers.image.description="lwmacct"
LABEL org.opencontainers.image.licenses=MIT
EOF
	)
	{
		cd "$(dirname "$_sh_path")" || exit 1
		echo "$_dockerfile" >Dockerfile

		_ghcr_source=$(git remote get-url origin | head -n1 | sed 's|git@github.com:|https://github.com/|' | sed 's|.git$||')
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
		_buildcache="$_registry/$_pro_name:cache"
		echo "image: $_repository"
		echo "cache: $_buildcache"
		echo "-----------------------------------"
		docker buildx build --builder default --platform linux/amd64 -t "$_repository" --network host --progress plain --load . && {
			# false/false
			if false; then
				docker rm -f sss >/dev/null 2>&1 || true
				docker run -itd --name=sss \
					--restart=unless-stopped \
					--network=host \
					--privileged=false \
					"$_repository"
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

ghcr.io/lwmacct/250210-cr-docker:28.5.2-dind-260408


EOF
}
