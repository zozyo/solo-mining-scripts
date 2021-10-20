#!/bin/bash

basedir=$(cd `dirname $0`;pwd)
scriptdir=$basedir/scripts
installdir=/opt/phala
language_file=/tmp/language
install_mode="0"
lang_code="en_us"

select_language()
{
	local language_num
	while true ; do
		cat $basedir/i18n/lang_list
		read -n1 -p "Please select the language number you need 请选择需要的语言编号: " language_num
		expr $language_num + 0 &> /dev/null
		if [ $? -eq 0 ] ; then
			lang_code=$(tail -n +$language_num $basedir/i18n/lang_match | head -n 1)
			cp $basedir/i18n/$lang_code $language_file
			break
		else
			printf "ERROR. please re-enter 输入错误，请重新输入:\n"
		fi
	done
	echo
}

choose_node()
{
	while true ; do
		sed -n '6,9p;10q' $language_file
		read -n1 install_mode
		expr $install_mode + 0 &> /dev/null
		if [ $? -eq 0 ] && [ $install_mode -ge 1 ] && [ $install_mode -le 3 ]; then
			break
		else
			sed -n '10p;11q' $language_file
		fi
	done
}

install()
{
	sed -n '1p;2q' $language_file

	if [ -f /opt/phala/scripts/phala.sh ]; then
		sed -n '2p;3q' $language_file
		/opt/phala/scripts/phala.sh uninstall
	fi
	sed -n '3p;4q' $language_file
	if [ ! -f $installdir ]; then mkdir -p $installdir; fi
	if [ -f $installdir/.env ]; then
		cp $basedir/.env $installdir
	fi
	cp $basedir/console.js $installdir
	cp $basedir/docker-compose.yml.$install_mode $installdir/docker-compose.yml
	sed -i "16c MODE=$install_mode" $installdir/.env
	sed -i "18c LANG_CODE=$lang_code" $installdir/.env

	cp -r $basedir/scripts/ $installdir/scripts

	cp $language_file $installdir/language

	sed -n '4p;5q' $language_file
	chmod +x $installdir/scripts/phala.sh
	ln -s $installdir/scripts/phala.sh /usr/bin/phala

	sed -n '5p;6q' $language_file
}

if [ $(id -u) -ne 0 ]; then
	echo "Please run with sudo!"
	echo "请使用sudo运行!"
	exit 1
fi

select_language
if [ $? -eq 0 ]; then
	choose_node
	if [ $? -eq 0 ]; then
		install
	fi
fi
