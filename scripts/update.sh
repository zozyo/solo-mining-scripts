#!/bin/bash

function download_script()
{
	if ! type wget unzip > /dev/null; then apt-get install -y wget unzip;fi
	for i in `seq 0 4`; do
		wget https://github.com/Phala-Network/solo-mining-scripts/archive/main.zip -O /tmp/main.zip &> /dev/null
		if [ $? -ne 0 ]; then
			log_err $(sed -n '55,p;56q' $language_file)
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
		log_info $(sed -n '56,p;57q' $language_file)
		sed -i "15c version=$(cat /tmp/phala/solo-mining-scripts-main/.env | awk -F "=" 'NR==15 {print $NF}')" $installdir/.env
		exit 1
	fi
	rm -rf /tmp/phala /tmp/main.zip
}

function update_script()
{
	log_info "----------更新 phala 脚本----------"
	download_script
	rm -rf /opt/phala/scripts /usr/bin/phala
	cp -r /tmp/phala/solo-mining-scripts-main/scripts/ /opt/phala/scripts
	cp -r /tmp/phala/solo-mining-scripts-main/docker-compose.yml /opt/phala
	chmod +x /opt/phala/scripts/phala.sh
	ln -s /opt/phala/scripts/phala.sh /usr/bin/phala
	log_success "----------更新完成----------"
	sed -i "15c version=$(cat /tmp/phala/solo-mining-scripts-main/.env | awk -F "=" 'NR==15 {print $NF}')" $installdir/.env
	rm -rf /tmp/phala /tmp/main.zip
}

function update_clean()
{
	log_info "----------删除 Docker 镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry phala-pruntime-bench khala-node"
	log_info "----------删除节点数据----------"
	for container_name in phala-node phala-pruntime phala-pherry phala-pruntime-bench phala-sgx_detect
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			docker container stop $container_name
			docker container rm --force $container_name
			case $container_name in
				phala-node)
					docker image rm $(awk -F "=" 'NR==1 {print $2}' $installdir/.env)
					local node_dir=$(awk -F '[=:]' 'NR==4 {print $2}' $installdir/.env)
					if [ -d $node_dir ]; then rm -rf $node_dir;fi
					;;
				phala-pruntime)
					docker image rm $(awk -F "=" 'NR==2 {print $2}' $installdir/.env)
					local pruntime_dir=$(awk -F '[=:]' 'NR==5 {print $2}' $installdir/.env)
					if [ -d $pruntime_dir ]; then rm -rf $pruntime_dir;fi
					;;
				phala-pherry)
					docker image rm $(awk -F "=" 'NR==3 {print $2}' $installdir/.env)
					;;
				*)
					break
			esac
		fi
	done
	log_success "----------成功删数据----------"

	start
}

function update_noclean()
{
	log_info "----------更新挖矿套件镜像----------"
	log_info "关闭 phala-node phala-pruntime phala-pherry phala-pruntime-bench"
	for container_name in phala-node phala-pruntime phala-pherry phala-pruntime-bench phala-sgx_detect
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			docker container stop $container_name
			docker container rm --force $container_name
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

	start
	log_success "----------更新成功----------"
}

function update()
{
	case "$1" in
		clean)
			update_clean
			;;
		script)
			update_script
			;;
		"")
			update_noclean
			;;
		*)
			phala_help
			break
	esac
}
