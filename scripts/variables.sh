#!/bin/bash

installdir=/opt/phala
language_file=$installdir/language
running_mode=$(cat $installdir/.env | awk -F "=" 'NR==16 {print $NF}')
detect_result=""
khala_substrate_ws_endpoint="wss://khala.api.onfinality.io/public-ws"
kusama_substrate_ws_endpoint="wss://pub.elara.patract.io/kusama"
sgx_detect_image="swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest"
docker_mirror="deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
docker_compose_url="https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)"
node_url="https://deb.nodesource.com/setup_lts.x"
yq_url="https://github.com/mikefarah/yq/releases/download/v4.11.2/yq_linux_amd64.tar.gz"
script_url="https://github.com/zozyo/solo-mining-scripts/archive/refs/heads/node-separation.zip"
