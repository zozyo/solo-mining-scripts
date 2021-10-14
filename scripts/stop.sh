#!/bin/bash

function stop()
{
	case $1 in
		all)
			for container_name in phala-node phala-pruntime phala-pherry
			do
				if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then docker container rm --force $container_name; fi
			done
			;;
		node)
			if [ ! -z $(docker container ls -q -f "name=phala-node") ]; then
				docker container rm --force phala-node
			else
				log_info $(sed -n '50,p;51q' $language_file)
			fi
			;;
		pruntime)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime") ]; then
				docker container rm --force phala-pruntime
			else
				log_info $(sed -n '51,p;52q' $language_file)
			fi
			;;
		pherry)
			if [ ! -z $(docker container ls -q -f "name=phala-pherry") ]; then
				docker container rm --force phala-pherry
			else
				log_info $(sed -n '52,p;53q' $language_file)
			fi
			;;
		*)
			phala_help
			break
	esac
}
