#!/bin/bash

scriptdir=$installdir/scripts

source $scriptdir/variables.sh
source $scriptdir/utils.sh
source $scriptdir/config.sh
source $scriptdir/install_phala.sh
source $scriptdir/logs.sh
source $scriptdir/start.sh
source $scriptdir/status.sh
source $scriptdir/stop.sh
source $scriptdir/uninstall.sh
source $scriptdir/update.sh
source $scriptdir/help.sh
source $scriptdir/sgx_test.sh

if [ $(id -u) -ne 0 ]; then
	sed -n '11p;12q' $language_file
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
		check_version
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
		logs $2
		;;
	uninstall)
		uninstall
		;;
	sgx-test)
		sgx_test
		;;
	*)
		phala_help
		;;
esac

exit 0
