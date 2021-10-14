#!/bin/bash

function sgx_test()
{
	local sgx_detect_image="swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest"

	if ! type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then install_depenencies;fi
	detect_driver
	if [ $detect_result = "00000" ]; then install_driver;fi

	case "$detect_result" in
		11110)
			docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/enclave --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision $sgx_detect_image
			;;
		01110)
			docker run -ti --rm --name phala-sgx_detect --device /dev/sgx/provision --device /dev/sgx_enclave --device /dev/sgx_provision $sgx_detect_image
			;;
		00110)
			docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision $sgx_detect_image
			;;
		00010)
			docker run -ti --rm --name phala-sgx_detect --device /dev/sgx_provision $sgx_detect_image
			;;
		00001)
			docker run -ti --rm --name phala-sgx_detect --device /dev/isgx $sgx_detect_image
			;;
		*)
			log_info $(sed -n '54,p;55q' $language_file)
			exit 1
			;;
	esac
}
