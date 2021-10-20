#!/bin/bash

function logs()
{
	case $1 in
		"")
			cd $installdir
			docker-compose logs -f
			;;
		node)
			if [ ! -z $(docker container ls -q -f "name=phala-node") ]; then
				docker logs -f phala-node
			else
				log_info $(sed -n '50p;51q' $language_file)
			fi
			;;
		pruntime)
			if [ ! -z $(docker container ls -q -f "name=phala-pruntime") ]; then
				docker logs -f phala-pruntime
			else
				log_info $(sed -n '51p;52q' $language_file)
			fi
			;;
		pherry)
			if [ ! -z $(docker container ls -q -f "name=phala-pherry") ]; then
				docker logs -f phala-pherry
			else
				log_info $(sed -n '52p;53q' $language_file)
			fi
			;;
		*)
			phala_help
			break
	esac
}
