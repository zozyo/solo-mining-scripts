#!/bin/bash

help_config()
{
cat << EOF
Usage:
	help			帮助信息
	show			查看配置信息（直接看到配置文件所有信息）
	set			重新配置
EOF
}

config_show()
{
	cat $installdir/.env
}

config_set_all()
{
	local cores
	while true ; do
		cores=8
		expr $cores + 0 &> /dev/null
		if [ $? -eq 0 ] && [ $cores -ge 1 ] && [ $cores -le 32 ]; then
			sed -i "6c CORES=$cores" $installdir/.env
			break
		else
			printf "请输入大于1小于32的整数，该数据不正确，请重新输入！\n"
		fi
	done

	local node_name
	while true ; do
		node_name=jyjf
		if [[ $node_name =~ \ |\' ]]; then
			printf "节点名称不能包含空格，请重新输入!\n"
		else
			sed -i "7c NODE_NAME=$node_name" $installdir/.env
			break
		fi
	done

	local mnemonic=""
	local gas_adress=""
	local balance=""
	while true ; do
		mnemonic="replaceme"
		if [ -z "$mnemonic" ] || [ $(node $installdir/console.js utils verify "$mnemonic") == "Cannot decode the input" ]; then
			printf "请输入合法助记词,且不能为空！\n"
		else
			gas_adress=$(node $installdir/console.js utils verify "$mnemonic")
			balance=$(node $installdir/console.js --substrate-ws-endpoint "wss://khala.api.onfinality.io/public-ws" chain free-balance $gas_adress 2>&1)
			balance=$(echo $balance | awk -F " " '{print $NF}')
			balance=$(echo "$balance / 1000000000000"|bc)
			if [ $(echo "$balance > 0.1"|bc) -eq 1 ]; then
				sed -i "8c MNEMONIC=$mnemonic" $installdir/.env
				sed -i "9c GAS_ACCOUNT_ADDRESS=$gas_adress" $installdir/.env
				break
			else
				printf "账户PHA小于0.1，请重新输入！\n"
				break
			fi
		fi
	done

	local pool_addr=""
	while true ; do
		pool_addr=45Kio9yJDLyWX5yUc2QmKo4RR42oT6YvDWB6tv2HFq1fPByd
		if [ -z "$pool_addr" ] || [ $(node $installdir/console.js utils verify "$pool_addr") == "Cannot decode the input" ]; then
			printf "请输入合法抵押池账户地址，且不能为空！\n"
		else
			sed -i "10c OPERATOR=$pool_addr" $installdir/.env
			break
		fi
	done
}

config()
{
	log_info "----------测试信用等级，正在等待Intel下发IAS远程认证报告！----------"
	local Level=$(phala sgx-test | awk '/confidenceLevel =/ {print $3 }' | tr -cd "[0-9]")
	if [ $(echo "1 <= $Level" | bc) -eq 1 ] && [ $(echo "$Level <= 5" | bc) -eq 1 ]; then
		log_info "您的信任等级是：$Level"
		case "$1" in
			show)
				config_show
				;;
			set)
				config_set_all
				;;
			*)
				help_config
				break
		esac
	else
		log_info "----------Intel IAS认证没有通过，请检查您的主板或网络！----------"
		exit 1
	fi
}
