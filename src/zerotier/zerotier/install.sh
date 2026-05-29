#! /bin/sh

source /jffs/softcenter/scripts/base.sh
eval `dbus export zerotier_`
eval `dbus export softcenter_arch`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL=
DIR=$(cd $(dirname $0); pwd)
module=${DIR##*/}

get_model(){
	local ODMPID=$(nvram get odmpid)
	local PRODUCTID=$(nvram get productid)
	if [ -n "${ODMPID}" ];then
		MODEL="${ODMPID}"
	else
		MODEL="${PRODUCTID}"
	fi
}

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
	local PKG_ARCH=$(cat ${DIR}/.arch)
	case $state in
		1)
			echo_date "本插件适用于${PKG_ARCH}架构平台！"
			echo_date "你的${softcenter_arch}架构平台不能安装！！!"
			echo_date "退出安装！"
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 1
			;;
		0|*)
			rm -rf /tmp/${module}* >/dev/null 2>&1
			exit 0
			;;
	esac
}

platform_test(){
	if [ ! -d "/jffs/softcenter" ];then
		echo_date "机型：${MODEL} $(nvram get firmver)_$(nvram get buildno)_$(nvram get extendno) 不符合安装要求，无法安装插件！"
		exit_install 1
	fi
}

copy() {
	# echo_date "$*" 2>&1
	"$@" 2>/dev/null
	# "$@" 2>&1
	if [ "$?" != "0" ];then
		echo_date "复制文件错误！可能是/jffs分区空间不足！"
		echo_date "尝试删除本次已经安装的文件..."
		echo_date "删除zerotier插件相关文件！"
		rm -rf /tmp/zerotier* >/dev/null 2>&1
		rm -rf /jffs/softcenter/bin/zerotier* >/dev/null 2>&1
		rm -rf /jffs/softcenter/res/icon-zerotier.png >/dev/null 2>&1
		rm -rf /jffs/softcenter/res/zt_*.png >/dev/null 2>&1
		rm -rf /jffs/softcenter/scripts/zerotier_* >/dev/null 2>&1
		rm -rf /jffs/softcenter/scripts/uninstall_zerotier.sh >/dev/null 2>&1
		rm -rf /jffs/softcenter/webs/Module_zerotier.asp >/dev/null 2>&1
		find /jffs/softcenter/init.d -name "*zerotier*" | xargs rm -rf
		exit 1
	fi
}

install_now(){
	# stop first
	if [ "${zerotier_enable}" == "1" -a -f "/jffs/softcenter/scripts/zerotier_config.sh" ];then
		echo_date "先关闭zerotier插件，保证文件更新成功..."
		/jffs/softcenter/scripts/zerotier_config.sh stop
	fi

	# remove some file first
	rm -rf /jffs/softcenter/bin/zerotier* >/dev/null 2>&1
	rm -rf /jffs/softcenter/res/icon-zerotier.png >/dev/null 2>&1
	rm -rf /jffs/softcenter/res/zt_*.png >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/zerotier_* >/dev/null 2>&1
	rm -rf /jffs/softcenter/scripts/uninstall_zerotier.sh >/dev/null 2>&1
	rm -rf /jffs/softcenter/webs/Module_zerotier.asp >/dev/null 2>&1
	find /jffs/softcenter/init.d -name "*zerotier*" | xargs rm -rf
	
	# isntall file
	echo_date "安装插件相关文件..."
	local ARCH=$(uname -m)
	cd /tmp
	copy cp -rf /tmp/${module}/bin/* /jffs/softcenter/bin/
	copy cp -rf /tmp/${module}/res/* /jffs/softcenter/res/
	copy cp -rf /tmp/${module}/scripts/* /jffs/softcenter/scripts/
	copy cp -rf /tmp/${module}/webs/* /jffs/softcenter/webs/
	copy cp -rf /tmp/${module}/uninstall.sh /jffs/softcenter/scripts/uninstall_${module}.sh
	ln -sf /jffs/softcenter/scripts/zerotier_config.sh /jffs/softcenter/init.d/S99zerotier.sh
	ln -sf /jffs/softcenter/scripts/zerotier_config.sh /jffs/softcenter/init.d/N99zerotier.sh
	cd /jffs/softcenter/bin/
	ln -sf zerotier-one zerotier-cli
	ln -sf zerotier-one zerotier-idtool

	# Permissions
	chmod +x /jffs/softcenter/bin/${module}*
	chmod +x /jffs/softcenter/scripts/${module}_*
	chmod +x /jffs/softcenter/init.d/S99zerotier.sh

	# intall different UI
	set_skin

	# dbus value
	echo_date "设置插件默认参数..."
	dbus set ${module}_version="$(/jffs/softcenter/bin/zerotier-one -v)"
	dbus set softcenter_module_${module}_version="$(cat $DIR/version)"
	dbus set softcenter_module_${module}_install="1"
	dbus set softcenter_module_${module}_name="${module}"
	dbus set softcenter_module_${module}_title="ZeroTier"
	dbus set softcenter_module_${module}_description="ZeroTier 内网穿透"

	# re-enable
	if [ "${zerotier_enable}" == "1" -a -f "/jffs/softcenter/scripts/zerotier_config.sh" ];then
		echo_date "安装完毕，重新启用${module}插件！"
		/jffs/softcenter/scripts/zerotier_config.sh start
	fi
	
	# finish
	echo_date "${module}插件安装完毕！"
	exit_install
}

install(){
	get_model
	platform_test
	install_now
}

install

