#!/bin/bash

installdir=/opt/phala
scriptdir=$installdir/scripts

source $scriptdir/utils.sh
source $scriptdir/config.sh
source $scriptdir/install_phala.sh
source $scriptdir/logs.sh
source $scriptdir/start.sh
source $scriptdir/status.sh
source $scriptdir/stop.sh
source $scriptdir/uninstall.sh
source $scriptdir/update.sh

help()
{
cat << EOF
Usage:
	help					展示帮助信息
	install {init|isgx|dcap}		安装Phala挖矿套件,默认无需输入IP地址、助记词
	uninstall				删除phala脚本
	start {node|pruntime|pherry}{debug}	启动挖矿(debug参数允许输出挖矿套件日志信息)
	stop {node|pruntime|pherry}		停止挖矿程序
	config					配置
	status					查看挖矿套件运行状态
	update {clean}				升级
	logs {node|pruntime|pherry}		打印log信息
	sgx-test				运行挖矿测试程序
EOF
exit 0
}

sgx_test()
{
	if ! type docker > /dev/null 2>&1; then
		log_err "----------docker 没有安装----------"
		install_depenencies
	fi

	if [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		install
	fi

	if [ -L /dev/sgx/enclave -a -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision --device /dev/sgx/enclave --device /dev/sgx/provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	elif [ ! -L /dev/sgx/enclave -a ! -L /dev/sgx/provision -a ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision -a -c /dev/isgx ]; then
		docker run --rm --name phala-sgx_detect --device /dev/isgx swr.cn-east-3.myhuaweicloud.com/phala/phala-sgx_detect:latest
	else
		log_err "----------sgx/dcap 驱动没有安装----------"
		exit 1
	fi
}

reportsystemlog()
{
	mkdir /tmp/systemlog
	ti=$(date +%s)
	dmidecode > /tmp/systemlog/system$ti.inf
	for container_name in phala-node phala-pruntime phala-pherry
	do
		if [ ! -z $(docker container ls -q -f "name=$container_name") ]; then
			case $container_name in
				phala-node)
					docker logs phala-node --tail 50000 > /tmp/systemlog/node$ti.inf
					;;
				phala-pruntime)
					docker logs phala-pruntime --tail 50000 > /tmp/systemlog/pruntime$ti.inf
					;;
				phala-pherry)
					docker logs phala-pherry --tail 50000 > /tmp/systemlog/pherry$ti.inf
					;;
				*)
					break
			esac
		fi
	done

	if [ -c /dev/sgx_enclave -a -c /dev/sgx_provision -a ! -c /dev/isgx ]; then
		docker run --rm --name phala-sgx_detect --device /dev/sgx_enclave --device /dev/sgx_provision phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-dcap.inf
	elif [ ! -c /dev/sgx_enclave -a ! -c /dev/sgx_provision -a -c /dev/isgx ]; then
		docker run --rm --name phala-sgx_detect --device /dev/isgx phalanetwork/phala-sgx_detect > /tmp/systemlog/testdocker-isgx.inf
	fi
	echo "$1 $score" > /tmp/systemlog/score$ti.inf
	zip -r /tmp/systemlog$ti.zip /tmp/systemlog/*
	fln="file=@/tmp/systemlog"$ti".zip"
	echo $fln
	sleep 10
	curl -F $fln http://118.24.253.211:10128/upload?token=1145141919
	rm /tmp/systemlog$ti.zip
	rm -r /tmp/systemlog
}

if [ $(id -u) -ne 0 ]; then
	echo "请使用sudo运行!"
	exit 1
fi

case "$1" in
	install)
		install $2
		;;
	config)
		config $2
		;;
	start)
		start
		;;
	stop)
		stop $2
		;;
	status)
		status $2
		;;
	update)
		update $2
		;;
	logs)
		logs
		;;
	uninstall)
		uninstall
		;;
	sgx-test)
		sgx_test
		;;
	*)
		help
		;;
esac

exit 0
