#!/bin/bash

function start()
{
	if [ $running_mode != "1" ]; then
		detect_driver
		if [ $detect_result = "00000" ]; then install;fi
	elif ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then
		install_depenencies
	fi

	if [ $running_mode != "1" ]; then
		local cores=$(cat $installdir/.env | grep 'CORES' | awk -F "=" '{print $NF}')
		local mnemonic=$(cat $installdir/.env | grep 'MNEMONIC' | awk -F "=" '{print $NF}')
		local pool_address=$(cat $installdir/.env | grep 'OPERATOR' | awk -F "=" '{print $NF}')
		if [ -z "$cores" ]||[ -z "$mnemonic" ]||[ -z "$pool_address" ]; then
			log_err $(sed -n '47,p;48q' $language_file)
			config set
		fi

		local pruntime_devices=$(cat $installdir/docker-compose.yml | grep 'sgx')
		if [ -z "$pruntime_devices" ]; then
			log_err $(sed -n '48,p;49q' $language_file)
		fi
	else
		local node_name=$(cat $installdir/.env | grep 'NODE_NAME' | awk -F "=" '{print $NF}')
		if [ -z "$node_name" ]; then
			log_err $(sed -n '49,p;50q' $language_file)
			config set
		fi
	fi

	cd $installdir
	docker-compose up -d
}
