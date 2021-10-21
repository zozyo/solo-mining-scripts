#!/bin/bash

function config_show()
{
	cat $installdir/.env
}

function config_set_node()
{
	local node_name
	while true ; do
		read -p "$(sed -n '32p;33q' $language_file)" node_name
		if [[ $node_name =~ \ |\' ]]; then
			log_err $(sed -n '33p;34q' $language_file)
		else
			sed -i "7c NODE_NAME=$node_name" $installdir/.env
			break
		fi
	done
}

function config_set_worker()
{
	local cores
	while true ; do
		read -p "$(sed -n '34p;35q' $language_file)" cores
		expr $cores + 0 &> /dev/null
		if [ $? -eq 0 ] && [ $cores -ge 1 ] && [ $cores -le 32 ]; then
			sed -i "6c CORES=$cores" $installdir/.env
			break
		else
			log_err $(sed -n '35p;36q' $language_file)
		fi
	done

	local mnemonic=""
	local gas_adress=""
	local balance=""
	while true ; do
		read -p "$(sed -n '36p;37q' $language_file)" mnemonic
		if [ -z "$mnemonic" ] || [ $(node $installdir/console.js utils verify "$mnemonic") == "Cannot decode the input" ]; then
			log_err $(sed -n '37p;38q' $language_file)
		else
			gas_adress=$(node $installdir/console.js utils verify "$mnemonic")
			balance=$(node $installdir/console.js --substrate-ws-endpoint $khala_substrate_ws_endpoint chain free-balance $gas_adress 2>&1)
			balance=$(echo $balance | awk -F " " '{print $NF}')
			balance=$(echo "$balance / 1000000000000"|bc)
			if [ $(echo "$balance > 0.1"|bc) -eq 1 ]; then
				sed -i "8c MNEMONIC=$mnemonic" $installdir/.env
				sed -i "9c GAS_ACCOUNT_ADDRESS=$gas_adress" $installdir/.env
				break
			else
				log_err $(sed -n '38,p;39q' $language_file)
			fi
		fi
	done

	local pool_addr=""
	while true ; do
		read -p "$(sed -n '39p;40q' $language_file)" pool_addr
		if [ -z "$pool_addr" ] || [ $(node $installdir/console.js utils verify "$pool_addr") == "Cannot decode the input" ]; then
			log_err $(sed -n '40p;41q' $language_file)
		else
			sed -i "10c OPERATOR=$pool_addr" $installdir/.env
			break
		fi
	done
}

function config_set_node_address()
{
	local node_ip_address=""
	while true ; do
		read -p "$(sed -n '41p;42q' $language_file)" node_ip_address
		nc -z -w 5 $node_ip_address 9944 2>/dev/null
		if [ $? -ne 0 ]; then
			log_err $(sed -n '42p;43q' $language_file)
		else
			sed -i "17c NODE_ADDRESS=$node_ip_address" $installdir/.env
			break
		fi
	done
}

function config_set_all()
{
	case "$running_mode" in
		1)
			config_set_node
			;;
		2)
			config_set_worker
			config_set_node_address
			;;
		3)
			config_set_node
			config_set_worker
			;;
		*)
			exit 1
			;;
	esac
}

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

function check_kernel()
{
	if version_gt $(uname -r|awk -F "-" '{print $1}') "5.10"; then
		log_err $(sed -n '43p;44q' $language_file)
		exit 1
	fi
}

function check_sgx()
{
	log_info $(sed -n '44p;45q' $language_file)
	local Level=$(phala sgx-test | awk '/confidenceLevel =/ {print $3 }' | tr -cd "[0-9]")
	if [ -z $Level ]; then
		log_err $(sed -n '45p;46q' $language_file)
		exit 1
	elif [ $(echo "1 <= $Level" | bc) -eq 1 ] && [ $(echo "$Level <= 5" | bc) -eq 1 ]; then
		log_info "$(sed -n '46p;47q' $language_file)$Level"
	fi
}

function config()
{
	case "$1" in
		show)
			config_show
			;;
		set)
			check_kernel
			if [ $running_mode != "1" ]; then check_sgx; fi
			config_set_all
			;;
		*)
			phala_help
			break
	esac
}
