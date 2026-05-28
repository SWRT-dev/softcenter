#! /bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export filebrowser_)
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
	local TITLE="FileBrowser"
	local DESCR="FileBrowser：您的可视化路由文件管理系统"
	local PLVER=$(cat ${DIR}/version)

	# stop before install
	if [ "$(dbus get filebrowser_enable)" == "1" -a -f "/jffs/softcenter/scripts/filebrowser_start.sh" ];then
		echo_date "安装前先关闭插件..."
		/jffs/softcenter/scripts/filebrowser_start.sh stop
	fi

	# remove before install
	echo_date 清理旧文件
	if [ -f "/jffs/softcenter/bin/filebrowser.db" ];then
		echo_date 发现数据库文件/jffs/softcenter/bin/filebrowser.db
		echo_date 将保留数据库。若要重置配置，请手动删除后重启服务。
	fi
	find /jffs/softcenter/scripts/ -name "filebrowser*.sh" | xargs rm -rf
	rm -rf /jffs/softcenter/webs/Module_filebrowser*
	rm -rf /jffs/softcenter/res/icon-filebrowser.png
	rm -rf /jffs/softcenter/bin/filebrowser
	find /jffs/softcenter/init.d/ -name "*filebrowser.sh" | xargs rm -rf

	# install file
	echo_date "安装插件相关文件..."
	cd /tmp
	echo_date 复制相关二进制文件！此步时间可能较长！
	cp -rf $DIR/bin/* /jffs/softcenter/bin/
	echo_date 复制相关的脚本文件！
	cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
	cp -rf $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_filebrowser.sh
	echo_date 复制相关的网页文件！
	cp -rf $DIR/webs/* /jffs/softcenter/webs/
	cp -rf $DIR/res/* /jffs/softcenter/res/
	echo_date 创建一些文件的软链接！
	[ ! -L "/jffs/softcenter/init.d/N99filebrowser.sh" ] && ln -sf /jffs/softcenter/scripts/filebrowser_start.sh /jffs/softcenter/init.d/N99filebrowser.sh
	# Permissions
	echo_date 为新安装文件赋予执行权限...
	chmod 755 /jffs/softcenter/scripts/*filebrowser*
	chmod 755 /jffs/softcenter/bin/filebrowser*

	
	# 离线安装时设置软件中心内储存的版本号等
	echo_date 清除冗余运行参数
	values=$(dbus list filebrowser_ | cut -d "=" -f 1)
	for value in $values
	do
		dbus remove $value
	done

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
	if [ "$(dbus get filebrowser_enable)" == "1" -a -f "/jffs/softcenter/scripts/filebrowser_start.sh" ];then
		echo_date "重新开启插件..."
		/jffs/softcenter/scripts/filebrowser_start.sh start
	fi

	# finish
	echo_date "${TITLE}插件安装完毕！"
	exit_install
}

install(){
	install_now
}

install

