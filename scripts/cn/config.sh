#!/bin/bash

config_help()
{
cat << EOF
Usage:
	help			帮助信息
	show			查看配置信息
	set			重新设置
EOF
}

config_show()
{
	cat $basedir/config.json | jq .
}

config_set_all()
{
	local node_name=""
	read -p "输入节点名称: " node_name
	node_name=`echo "$node_name"`
	while [[ x"$node_name" =~ \ |\' ]]; do
		read -p "节点名称不能包含空格，请重新输入：" node_name
	done
	sed -i "11c\\   - NODE_NAME=\"$node_name\"" $basedir/docker-compose.yml &>/dev/null
	log_success "设置节点名称为: '$node_name' 成功"
	sed -i "39c\\      \"--substrate-ws-endpoint=ws://0.0.0.0:9944\"," $basedir/docker-compose.yml &>/dev/null
	sed -i "40c\\      \"--pruntime-endpoint=http://0.0.0.0:8000\"," $basedir/docker-compose.yml &>/dev/null

	local mnemonic=""
	read -p "输入你的Controllor账号助记词 : " mnemonic
	mnemonic=`echo "$mnemonic"`
	if [ x"$mnemonic" == x"" ]; then
		log_err "助记词不能为空"
		exit 1
	fi
	sed -i "38c\\      \"--mnemonic=$mnemonic\"," $basedir/docker-compose.yml &>/dev/null
	log_success "设置助记词为: '$mnemonic' 成功"
}

config()
{
	case "$1" in
		show)
			config_show
			;;
		set)
			config_set_all
			;;
		*)
			config_help
	esac
}
