#!/bin/bash

status()
{
	trap "clear;exit" 2
	while true; do
		local node_status="stop"
		local pruntime_status="stop"
		local pherry_status="stop"
		local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
		local node_block=$(curl -sH "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "system_syncState", "params":[]}' http://0.0.0.0:9933 | jq '.result.currentBlock')

		check_docker_status phala-node
		local res=$?
		if [ $res -eq 0 ]; then
			node_status="running"
		elif [ $res -eq 2 ]; then
			node_status="exited"
		fi

		clear
			printf "
---------------------------   10s刷新   ----------------------------------
--------------------------------------------------------------------------
	服务名称		服务状态		本地节点区块高度
--------------------------------------------------------------------------
	phala-node		${node_status}			${node_block}
--------------------------------------------------------------------------
	账户信息		内容
--------------------------------------------------------------------------
	节点名称           	${node_name}
--------------------------------------------------------------------------
"

	for i in `seq 0 9`
	do
		printf "$i "
		sleep 1
	done
	printf " 刷新中..."
    done
}
