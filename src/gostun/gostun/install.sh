#! /bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export gostun_`
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

install_now() {
	TITLE="Gostun NAT检测"
	DESCR="本机NAT类型检测工具，测得你路由网络的NAT类型上限"
	PLVER="$(cat "${DIR}/version" 2>/dev/null)"

	if [ ! -d "/jffs/softcenter" ] ; then
		echo_date "你的固件不适配，无法安装此插件包，请正确选择插件包！"
		exit_install 1
	fi

	echo_date "安装插件相关文件..."
	cp -rf ${DIR}/res/* /jffs/softcenter/res/
	cp -rf ${DIR}/scripts/* /jffs/softcenter/scripts/
	cp -rf ${DIR}/webs/* /jffs/softcenter/webs/
	cp -rf ${DIR}/bin/* /jffs/softcenter/bin/
	cp -rf ${DIR}/uninstall.sh /jffs/softcenter/scripts/uninstall_${module}.sh

	chmod 755 /jffs/softcenter/bin/gostun >/dev/null 2>&1
	chmod 755 /jffs/softcenter/scripts/${module}_*.sh >/dev/null 2>&1
	chmod 755 /jffs/softcenter/scripts/uninstall_${module}.sh >/dev/null 2>&1

	echo_date "设置插件默认参数..."
	dbus set ${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_version="${PLVER}"
	dbus set softcenter_module_${module}_install="1"
	dbus set softcenter_module_${module}_name="${module}"
	dbus set softcenter_module_${module}_title="${TITLE}"
	dbus set softcenter_module_${module}_description="${DESCR}"

	# keep user config on upgrade; treat "null" as empty
	old_server="$(dbus get gostun_server)"
	if [ -z "${old_server}" ] || [ "${old_server}" = "null" ]; then
		dbus set gostun_server="auto"
	elif [ "${old_server}" != "auto" ] && [ "${old_server}" != "custom" ]; then
		# migrate old fixed server selection to custom
		old_custom="$(dbus get gostun_custom)"
		if [ -z "${old_custom}" ] || [ "${old_custom}" = "null" ]; then
			dbus set gostun_custom="${old_server}"
		fi
		dbus set gostun_server="custom"
	fi
	old_custom="$(dbus get gostun_custom)"
	if [ -z "${old_custom}" ] || [ "${old_custom}" = "null" ]; then
		dbus set gostun_custom=""
	fi

	echo_date "${TITLE}插件安装完毕！"
	exit_install
}

install(){
	install_now
}

install
