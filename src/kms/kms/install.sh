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
	local TITLE="系统工具"
	local DESCR="kms"
	local PLVER=$(cat ${DIR}/version)

	# stop before install
	if [ "$(dbus get kms_enable)" == "1" -a -f "/jffs/softcenter/scripts/kms_config.sh" ];then
		echo_date "安装前先关闭插件..."
		/jffs/softcenter/scripts/kms_config.sh stop
	fi

	# remove before install
	rm -rf /jffs/softcenter/res/icon-kms.png >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/kms_* >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/uninstall_kms.sh >/dev/null 2>&1
	rm -rf /jffs/softcenter/webs/Module_kms.asp >/dev/null 2>&1
	find /jffs/softcenter/init.d -name "*kms*" | xargs rm -rf	

	# install file
	echo_date "安装插件相关文件..."
	cd /tmp
	cp -rf /tmp/kms/scripts/* /jffs/softcenter/scripts/
	cp -rf /tmp/kms/bin/* /jffs/softcenter/bin/
	cp -rf /tmp/kms/webs/* /jffs/softcenter/webs/
	cp -rf /tmp/kms/res/* /jffs/softcenter/res/
	# Permissions
	chmod +x /jffs/softcenter/scripts/kms*
	chmod +x /jffs/softcenter/bin/vlmcsd

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
	# start after install
	if [ "$(dbus get kms_enable)" == "1" -a -f "/jffs/softcenter/scripts/kms_config.sh" ];then
		echo_date "重新开启插件..."
		/jffs/softcenter/scripts/kms_config.sh start
	fi

	# finish
	echo_date "${TITLE}插件安装完毕！"
	exit_install
}

install(){
	install_now
}

install

