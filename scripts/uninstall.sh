#!/bin/bash

function uninstall()
{
	for container_name in phala-node phala-pruntime phala-pherry phala-sgx_detect
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			docker container stop $container_name
			docker container rm --force $container_name
		fi
		if [ -z $(docker images -q $container_name) ]; then
			case $container_name in
				phala-node)
					docker image rm $(awk -F "=" 'NR==1 {print $2}' $installdir/.env)
					if [ -d $(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env) ]; then rm -rf $(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env);fi
					;;
				phala-pruntime)
					docker image rm $(awk -F "=" 'NR==2 {print $2}' $installdir/.env)
					if [ -d $(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env) ]; then rm -rf $(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env);fi
					;;
				phala-pherry)
					docker image rm $(awk -F "=" 'NR==3 {print $2}' $installdir/.env)
					;;
				phala-sgx_detect)
					docker image rm swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
					;;
				*)
					break
			esac
		fi
	done
	remove_driver
	rm -rf $installdir/{scripts,docker-compose.yml,console.js}
	rm /usr/bin/phala

	log_success $(sed -n '53p;54q' $language_file)
}
