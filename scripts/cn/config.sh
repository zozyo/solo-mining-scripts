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
}

config()
{
				config_set_all
}
