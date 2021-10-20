#!/bin/bash

function download_script()
{
	if ! type wget unzip > /dev/null; then apt-get install -y wget unzip;fi
	for i in `seq 0 4`; do
		wget https://github.com/Phala-Network/solo-mining-scripts/archive/main.zip -O /tmp/main.zip &> /dev/null
		if [ $? -ne 0 ]; then
			log_err $(sed -n '54p;55q' $language_file)
		else
			break
		fi
	done
	unzip -o /tmp/main.zip -d /tmp/phala &> /dev/null
}

function check_version()
{
	download_script
	if [ "$(cat $installdir/.env | awk -F "=" 'NR==15 {print $NF}')" != "$(cat /tmp/phala/solo-mining-scripts-main/.env | awk -F "=" 'NR==15 {print $NF}')" ]&&[ -d /tmp/phala ]; then
		rm -rf /opt/phala/scripts /usr/bin/phala
		cp -r /tmp/phala/solo-mining-scripts-main/scripts/ /opt/phala/scripts
		cp -r /tmp/phala/solo-mining-scripts-main/docker-compose.yml.$running_mode /opt/phala
		chmod +x /opt/phala/scripts/phala.sh
		ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
		log_info $(sed -n '55p;56q' $language_file)
		sed -i "15c version=$(cat /tmp/phala/solo-mining-scripts-main/.env | awk -F "=" 'NR==15 {print $NF}')" $installdir/.env
		exit 1
	fi
	rm -rf /tmp/phala /tmp/main.zip
}

function update_script()
{
	log_info $(sed -n '56p;57q' $language_file)
	download_script
	rm -rf /opt/phala/scripts /usr/bin/phala
	cp -r /tmp/phala/solo-mining-scripts-main/scripts/ /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-main/docker-compose.yml /opt/phala
	chmod +x /opt/phala/scripts/phala.sh
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
	log_success $(sed -n '57p;58q' $language_file)
	sed -i "15c version=$(cat /tmp/phala/solo-mining-scripts-main/.env | awk -F "=" 'NR==15 {print $NF}')" $installdir/.env
	rm -rf /tmp/phala /tmp/main.zip
}

function update_docker()
{
	log_info $(sed -n '58p;59q' $language_file)
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
					;;
				phala-pruntime)
					docker image rm $(awk -F "=" 'NR==2 {print $2}' $installdir/.env)
					;;
				phala-pherry)
					docker image rm $(awk -F "=" 'NR==3 {print $2}' $installdir/.env)
					;;
				*)
					break
			esac
		fi
	done

	if [ $1 = "clean" ]; then
		log_info $(sed -n '60p;61q' $language_file)
		local node_dir=$(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
		if [ -d $node_dir ]; then rm -rf $node_dir;fi
		local pruntime_dir=$(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
		if [ -d $pruntime_dir ]; then rm -rf $pruntime_dir;fi
		log_success $(sed -n '61p;62q' $language_file)
	fi

	start
	log_success $(sed -n '57p;58q' $language_file)
}

function update()
{
	case "$1" in
		script)
			update_script
			;;
		"")
			update_docker $1
			;;
		*)
			phala_help
			break
	esac
}
