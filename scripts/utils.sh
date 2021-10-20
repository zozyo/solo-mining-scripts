#!/bin/bash

function echo_c()
{
	printf "\033[0;$1m$2\033[0m\n"
}

function log_info()
{
	echo_c 33 "$*"
}

function log_success()
{
	echo_c 32 "$*"
}

function log_err()
{
	echo_c 35 "$*"
}

function check_docker_status()
{
	local exist=`docker inspect --format '{{.State.Running}}' $1 2>/dev/null`
	if [ x"${exist}" == x"true" ]; then
		return 0
	elif [ "${exist}" == "false" ]; then
		return 2
	else
		return 1
	fi
}

function detect_driver()
{
	local dcap_check_1="0"
	local dcap_check_2="0"
	local dcap_check_3="0"
	local dcap_check_4="0"
	local isgx_check_1="0"

	if [ -L /dev/sgx/enclave ]; then dcap_check_1="1"; fi
	if [ -L /dev/sgx/provision ]; then dcap_check_2="1"; fi
	if [ -c /dev/sgx_enclave ]; then dcap_check_3="1"; fi
	if [ -c /dev/sgx_provision ]; then dcap_check_4="1"; fi
	if [ -c /dev/isgx ]; then isgx_check_1="1"; fi

	detect_result=$(echo $dcap_check_1$dcap_check_2$dcap_check_3$dcap_check_4$isgx_check_1)
}
