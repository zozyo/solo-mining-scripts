#!/bin/bash

config_help()
{
cat << EOF
Usage:
	help			show help information
	show			show configurations
	set			set configurations
EOF
}

config_show()
{
	cat $basedir/config.json | jq .
}

config_set_all()
{
	local node_name=""
	read -p "Enter phala node name: " node_name
	while [[ x"$node_name" =~ \ |\' ]]; do
		read -p "The node name can't contain spaces, please re-enter：" node_name
	done
	node_name=`echo "$node_name"`
	sed -i "2c \\  \"nodename\" : \"$node_name\"," $basedir/config.json &>/dev/null
	log_success "Set phala node name: '$node_name' successfully"
	local ipaddr=""
	read -p "Enter your local IP address: " ipaddr
	ipaddr=`echo "$ipaddr"`
	if [ x"$ipaddr" == x"" ] || [ `echo $ipaddr | awk -F . '{print NF}'` -ne 4 ]; then
		log_err "The IP address cannot be empty or the format is wrong"
		exit 1
	fi
	sed -i "3c \\  \"ipaddr\" : \"$ipaddr\"," $basedir/config.json &>/dev/null
	log_success "Set IP address: '$ipaddr' successfully"

	local mnemonic=""
	read -p "Enter your controllor mnemonic : " mnemonic
	mnemonic=`echo "$mnemonic"`
	if [ x"$mnemonic" == x"" ]; then
		log_err "Mnemonic cannot be empty"
		exit 1
	fi
	sed -i "4c \\  \"mnemonic\" : \"$mnemonic\"" $basedir/config.json &>/dev/null
	log_success "Set your controllor mnemonic: '$mnemonic' successfully"
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
