#!/bin/bash

function install_depenencies()
{
	log_info $(sed -n '12p;13q' $language_file)
	apt-get update
	if [ $? -ne 0 ]; then
		log_err $(sed -n '13p;14q' $language_file)
		exit 1
	fi

	log_info $(sed -n '14p;15q' $language_file)
	for i in `seq 0 4`; do
		for package in jq curl wget unzip zip docker docker-compose node yq dkms; do
			if ! type $package > /dev/null; then
				case $package in
					jq|curl|wget|unzip|zip|dkms)
						apt-get install -y $package
						;;
					docker)
						curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
						add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
						apt-get install -y docker-ce docker-ce-cli containerd.io
						usermod -aG docker $USER
						;;
					docker-compose)
						curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
						chmod +x /usr/local/bin/docker-compose
						;;
					node)
						curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
						apt-get install -y nodejs
						;;
					yq)
						wget https://github.com/mikefarah/yq/releases/download/v4.11.2/yq_linux_amd64.tar.gz -O /tmp/yq_linux_amd64.tar.gz
						tar -xvf /tmp/yq_linux_amd64.tar.gz -C /tmp
						mv /tmp/yq_linux_amd64 /usr/bin/yq
						rm /tmp/yq_linux_amd64.tar.gz
						;;
					*)
						break
				esac
			fi
		done
		if type jq curl wget unzip zip docker docker-compose node yq dkms > /dev/null; then
			break
		else
			log_err $(sed -n '15p;16q' $language_file)
			exit 1
		fi
	done
}

function remove_driver()
{
	if [ -f /opt/intel/sgxdriver/uninstall.sh ]; then
		log_info $(sed -n '16p;17q' $language_file)
		/opt/intel/sgxdriver/uninstall.sh
	fi
}

function install_progress()
{
	log_info $(sed -n '17p;18q' $language_file)
	for i in `seq 0 4`; do
		wget $1 -O /tmp/$2
		if [ $? -ne 0 ]; then
			log_err $(sed -n '18p;19q' $language_file)
		else
			break
		fi
	done

	if [ -f /tmp/$2 ]; then
		log_info $(sed -n '19p;20q' $language_file)
		chmod +x /tmp/$2
	else
		log_err $(sed -n '20p;21q' $language_file)
		exit 1
	fi

	log_info $(sed -n '21p;22q' $language_file)
	/tmp/$2
	if [ $? -ne 0 ]; then
		log_err $(sed -n '22p;23q' $language_file)
		exit 1
	else
		log_success $(sed -n '23p;24q' $language_file)
		rm /tmp/$2
	fi

	return 0
}

function install_driver()
{
	remove_driver
	install_progress $dcap_driverurl $dcap_driverbin
	if [ $? -ne 0 ]; then
		install_progress $isgx_driverurl $isgx_driverbin
		if [ $? -ne 0 ]; then
			log_err $(sed -n '24p;25q' $language_file)
			exit 1
		fi
	fi
}

function write_pruntime_devices()
{
	detect_driver
	case "$detect_result" in
		11110)
			log_info $(sed -n '25p;26q' $language_file)
			yq e -i '.services.phala-pruntime.devices = ["/dev/sgx/enclave","/dev/sgx/provision","/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
		;;
		01110)
			log_info $(sed -n '26p;27q' $language_file)
			yq e -i '.services.phala-pruntime.devices = ["/dev/sgx/provision","/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
			;;
		00110)
			log_info $(sed -n '27p;28q' $language_file)
			yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_enclave","/dev/sgx_provision"]' $installdir/docker-compose.yml
			;;
		00010)
			log_info $(sed -n '28p;29q' $language_file)
			yq e -i '.services.phala-pruntime.devices = ["/dev/sgx_provision"]' $installdir/docker-compose.yml
			;;
		00001)
			log_info $(sed -n '29p;30q' $language_file)
			yq e -i '.services.phala-pruntime.devices = ["/dev/isgx"]' $installdir/docker-compose.yml
			;;
		*)
			log_info $(sed -n '30p;31q' $language_file)
			exit 1
			;;
	esac
}

function install()
{
	case "$1" in
		"")
			install_depenencies
			if [ $running_mode != "1" ]; then
				install_driver
			fi
			;;
		dcap)
			remove_driver
			install_progress $dcap_driverurl $dcap_driverbin
			;;
		isgx)
			remove_driver
			install_progress $isgx_driverurl $isgx_driverbin
			;;
		*)
			phala_help
			exit 1
			;;
	esac

	write_pruntime_devices
}

if [ $(lsb_release -r | grep -o "[0-9]*\.[0-9]*") == "18.04" ]; then
	dcap_driverurl=$(awk -F '=' 'NR==11 {print $2}' $installdir/.env)
	dcap_driverbin=$(awk -F '/' 'NR==11 {print $NF}' $installdir/.env)
	isgx_driverurl=$(awk -F '=' 'NR==13 {print $2}' $installdir/.env)
	isgx_driverbin=$(awk -F '/' 'NR==13 {print $NF}' $installdir/.env)
elif [ $(lsb_release -r | grep -o "[0-9]*\.[0-9]*") = "20.04" ]; then
	dcap_driverurl=$(awk -F '=' 'NR==12 {print $2}' $installdir/.env)
	dcap_driverbin=$(awk -F '/' 'NR==12 {print $NF}' $installdir/.env)
	isgx_driverurl=$(awk -F '=' 'NR==14 {print $2}' $installdir/.env)
	isgx_driverbin=$(awk -F '/' 'NR==14 {print $NF}' $installdir/.env)
else
	log_err $(sed -n '31p;32q' $language_file)
	exit 1
fi
