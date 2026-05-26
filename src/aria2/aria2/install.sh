#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)
module=${DIR##*/}

set_skin(){
	local UI_TYPE=ASUSWRT
	local SC_SKIN=$(nvram get sc_skin)
	local SWRT_SKIN=$(nvram get swrt_skin)
	local TS_FLAG=$(grep -o "2ED9C3" /www/css/difference.css 2>/dev/null|head -n1)
	local ROG_FLAG=$(cat /www/form_style.css|grep -A1 ".tab_NW:hover{"|grep "background"|grep -o "2071044")
	local TUF_FLAG=$(cat /www/form_style.css|grep -A1 ".tab_NW:hover{"|grep "background"|grep -o "D0982C")
	if [ -n "${SWRT_SKIN}" ];then
		if [ "ts" == "${SWRT_SKIN}" ];then
			UI_TYPE="TS"
		elif [ "rog" == "${SWRT_SKIN}" ];then
			UI_TYPE="ROG"
		elif [ "tuf" == "${SWRT_SKIN}" ];then
			UI_TYPE="TUF"
		elif [ "swrt" == "${SWRT_SKIN}" ];then
			UI_TYPE="SWRT"
		fi
	elif [ -n "${TS_FLAG}" ];then
		UI_TYPE="TS"
	elif [ -n "${ROG_FLAG}" ];then
		UI_TYPE="ROG"
	elif [ -n "${TUF_FLAG}" ];then
		UI_TYPE="TUF"
	fi
	if [ -z "${SC_SKIN}" -o "${SC_SKIN}" != "${UI_TYPE}" ];then
		nvram set sc_skin="${UI_TYPE}"
		nvram commit
	fi
}

exit_install(){
	local state=$1
	case $state in
		1)
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 1
			;;
		0|*)
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 0
			;;
	esac
}

install_now(){
	# default value
	local TITLE="aria2"
	local DESCR="linux下载利器"
	local PLVER=$(cat ${DIR}/version)
	local aria2_version=`dbus get aria2_version`

	# stop before install
	if [ "$(dbus get aria2_enable)" == "1" -a -f "/jffs/softcenter/scripts/aria2_config.sh" ];then
		echo_date "安装前先关闭插件..."
		/jffs/softcenter/scripts/aria2_config.sh stop
	fi

	# remove before install
	rm -rf /jffs/softcenter/res/icon-aria2.png >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/aria2_* >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/uninstall_aria2.sh >/dev/null 2>&1
	rm -rf /jffs/softcenter/webs/Module_aria2.asp >/dev/null 2>&1
	find /jffs/softcenter/init.d -name "*aria2*" | xargs rm -rf

	# install file
	echo_date "安装插件相关文件..."
	cd /tmp
	cp -rf /tmp/aria2/bin/* /jffs/softcenter/bin/
	cp -rf /tmp/aria2/scripts/* /jffs/softcenter/scripts/
	cp -rf /tmp/aria2/webs/* /jffs/softcenter/webs/
	cp -rf /tmp/aria2/res/* /jffs/softcenter/res/
	cp -rf /tmp/aria2/uninstall.sh /jffs/softcenter/scripts/uninstall_aria2.sh
	[ ! -L "/jffs/softcenter/init.d/M99Aria2.sh" ] && ln -sf /jffs/softcenter/scripts/aria2_config.sh /jffs/softcenter/init.d/M99Aria2.sh
	[ ! -L "/jffs/softcenter/init.d/N99Aria2.sh" ] && ln -sf /jffs/softcenter/scripts/aria2_config.sh /jffs/softcenter/init.d/N99Aria2.sh

	# Permissions
	chmod +x /jffs/softcenter/bin/*
	chmod +x /jffs/softcenter/scripts/aria2*.sh
	chmod +x /jffs/softcenter/scripts/uninstall_aria2.sh

	# intall different UI
	set_skin

	# dbus value
	echo_date "设置插件默认参数..."
	dbus set ${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_install="1"
	dbus set softcenter_module_${module}_name="${module}"
	dbus set softcenter_module_${module}_title="${TITLE}"
	dbus set softcenter_module_${module}_description="${DESCR}"

	#some modify
	if [ "$aria2_version" == "1.5" ] || [ "$aria2_version" == "1.4" ] || [ "$aria2_version" == "1.3" ];then
		dbus set aria2_custom=Y2EtY2VydGlmaWNhdGU9L2V0Yy9zc2wvY2VydHMvY2EtY2VydGlmaWNhdGVzLmNydA==
	fi

	# start after install
	if [ "$(dbus get aria2_enable)" == "1" -a -f "/jffs/softcenter/scripts/aria2_config.sh" ];then
		echo_date "安装前先关闭插件..."
		/jffs/softcenter/scripts/aria2_config.sh start
	fi

	# finish
	echo_date "${TITLE}插件安装完毕！"
	exit_install
}

install(){
	install_now
}

install
