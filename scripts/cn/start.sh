#!/bin/bash

start()
{
	local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
	local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
	local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
	local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
	if ! type docker docker-compose node yq jq curl wget unzip zip >/dev/null 2>&1; then
		log_err "----------缺少重要依赖工具，请执行sudo phala install重新安装！----------"
		exit 1
	fi

	cd $installdir
	docker-compose up -d
	#docker run -dti --rm --name khala-node -e NODE_NAME=$node_name -e NODE_ROLE=MINER -p 40333:30333 -p 40334:30334 -v /var/khala-dev-node:/root/data phalanetwork/khala-node
}
