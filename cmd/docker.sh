#!/usr/bin/env bash

__main() {

	{
		_proxy="ghcr.nju.edu.cn/"
		_proxy="1181.s.kuaicdn.cn:11818/"
		_image1="${_proxy}ghcr.io/lwmacct/250210-cr-docker:29.4.0-dind-260408"
		_image2="$(docker images -q $_image1)"
		if [[ "$_image2" == "" ]]; then docker pull $_image1 && _image2="$(docker images -q $_image1)"; fi
	}

	_pro_data="/zfs/lwm/4444-test"
	_pro_name="$(echo "$_pro_data" | awk -F/ '{print $NF}')"
	_pro_ip="172.22.$(echo "$_pro_data" | grep -oE '[0-9]{4}' | sed 's/\(..\)\(..\)/\1.\2/; s/0\([0-9]\)/\1/g')"
	_pro_mac=$(echo "$_pro_ip" | md5sum | sed 's/^/88/; s/\(..\)/\1:/g; s/.$//' | cut -d: -f1-6)
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
    mem_limit: 64g
    cpus: "$_limit_cores"
    networks:
      dind:
        ipv4_address: "$_pro_ip"
        mac_address: "$_pro_mac"
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
