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
	local TITLE="ServerChan微信推送"
	local DESCR="从路由器推送状态及通知的工具。"
	local PLVER=$(cat ${DIR}/version)

	# stop before install
	if [ "$(dbus get serverchan_enable)" == "1" -a -f "/jffs/softcenter/scripts/serverchan_config.sh" ];then
		echo_date "安装前先关闭插件..."
		/jffs/softcenter/scripts/serverchan_config.sh stop
	fi

	# remove before install
	rm -rf /jffs/softcenter/serverchan >/dev/null 2>&1
	rm -rf /jffs/softcenter/res/icon-serverchan.png >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/serverchan_* >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/uninstall_serverchan.sh >/dev/null 2>&1
	rm -rf /jffs/softcenter/webs/Module_serverchan.asp >/dev/null 2>&1
	find /jffs/softcenter/init.d -name "*serverchan*" | xargs rm -rf	

	# install file
	echo_date "安装插件相关文件..."
	cd /tmp
	cp -rf /tmp/serverchan/res/icon-serverchan.png /jffs/softcenter/res/
	cp -rf /tmp/serverchan/scripts/* /jffs/softcenter/scripts/
	cp -rf /tmp/serverchan/webs/Module_serverchan.asp /jffs/softcenter/webs/
	[ ! -L "/jffs/softcenter/init.d/S99CRUserverchan.sh" ] && ln -sf /jffs/softcenter/scripts/serverchan_config.sh /jffs/softcenter/init.d/S99CRUserverchan.sh
	# Permissions
	chmod +x /jffs/softcenter/scripts/*

	# intall different UI
	set_skin

	# 设置默认值
	router_name=`echo $(nvram get model) | base64_encode`
	router_name_get=`dbus get serverchan_config_name`
	if [ -z "${router_name_get}" ]; then
		dbus set serverchan_config_name="${router_name}"
	fi
	router_ntp_get=`dbus get serverchan_config_ntp`
	if [ -z "${router_ntp_get}" ]; then
		dbus set serverchan_config_ntp="ntp1.aliyun.com"
	fi
	bwlist_en_get=`dbus get serverchan_dhcp_bwlist_en`
	if [ -z "${bwlist_en_get}" ]; then
		dbus set serverchan_dhcp_bwlist_en="1"
	fi
	_sckey=`dbus get serverchan_config_sckey`
	if [ -n "${_sckey}" ]; then
		dbus set serverchan_config_sckey_1=`dbus get serverchan_config_sckey`
		dbus remove serverchan_config_sckey
	fi
	[ -z "`dbus get serverchan_info_lan_macoff`" ] && dbus set serverchan_info_lan_macoff="1"
	[ -z "`dbus get serverchan_info_dhcp_macoff`" ] && dbus set serverchan_info_dhcp_macoff="1"
	[ -z "`dbus get serverchan_trigger_dhcp_macoff`" ] && dbus set serverchan_trigger_dhcp_macoff="1"
	# dbus value
	echo_date "设置插件默认参数..."
	dbus set ${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_install="1"
	dbus set softcenter_module_${module}_name="${module}"
	dbus set softcenter_module_${module}_title="${TITLE}"
	dbus set softcenter_module_${module}_description="${DESCR}"
	# start after install
	if [ "$(dbus get serverchan_enable)" == "1" -a -f "/jffs/softcenter/scripts/serverchan_config.sh" ];then
		echo_date "重新开启插件..."
		/jffs/softcenter/scripts/serverchan_config.sh start
	fi

	# finish
	echo_date "${TITLE}插件安装完毕！"
	exit_install
}

install(){
	install_now
}

install

