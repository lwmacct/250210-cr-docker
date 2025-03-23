#!/usr/bin/env bash

__main() {

  {
    # 镜像准备
    _image1="ghcr.io/lwmacct/250210-cr-docker:28.0.2-dind-2503230"
    _image2="$(docker images -q $_image1)"
    if [[ "$_image2" == "" ]]; then
      docker pull $_image1
      _image2="$(docker images -q $_image1)"
    fi
  }

  _pro_data="/zfs/lwm/4444-test"
  _pro_name="$(echo "$_pro_data" | awk -F/ '{print $NF}')"
  _pro_ip="172.22.$(echo "$_pro_data" | grep -oE '[0-9]{4}' | sed 's/\(..\)\(..\)/\1.\2/; s/0\([0-9]\)/\1/g')"

  _limit_cores=$(echo "$(nproc) * 0.6" | bc)
  cat <<EOF | docker compose -p "$_pro_name" -f - up -d --remove-orphans
services:
  docker:
    container_name: $_pro_name
    hostname: $_pro_name
    image: "$_image2"
    restart: always
    runtime: sysbox-runc
    privileged: false
    mem_limit: 32g
    cpus: "$_limit_cores"
    networks:
      dind:
        ipv4_address: "$_pro_ip"
    devices:
      - /dev/net/tun:/dev/net/tun:rwm
    volumes:
      - $_pro_data/data:/data
      - $_pro_data/docker/:/var/lib/docker
      - $_pro_data/docker/certs:/certs
    environment:
      - TZ=Asia/Shanghai
networks:
  dind:
    external: true
EOF
}

__help() {
  cat <<EOF

EOF
}

__main
