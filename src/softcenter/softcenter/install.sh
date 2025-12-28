#!/bin/sh

# Copyright (C) 2021-2025 SWRTdev
eval $(dbus export softcenter_firmware_version)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
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
	local TS_FLAG=$(grep -o "2ED9C3" /www/css/difference.css 2>/dev/null|head -n1)
	local ROG_FLAG=$(cat /www/form_style.css|grep -A1 ".tab_NW:hover{"|grep "background"|sed 's/,//g'|grep -o "2071044")
	local TUF_FLAG=$(cat /www/form_style.css|grep -A1 ".tab_NW:hover{"|grep "background"|sed 's/,//g'|grep -o "D0982C")
	local WRT_FLAG=$(cat /www/form_style.css|grep -A1 ".tab_NW:hover{"|grep "background"|sed 's/,//g'|grep -o "4F5B5F")

	if [ -n "${TS_FLAG}" ];then
		UI_TYPE="TS"
	else
		if [ -n "${TUF_FLAG}" ];then
			UI_TYPE="TUF"
		fi
		if [ -n "${ROG_FLAG}" ];then
			UI_TYPE="ROG"
		fi
		if [ -n "${WRT_FLAG}" ];then
			UI_TYPE="ASUSWRT"
		fi
	fi
	if [ -z "${SC_SKIN}" -o "${SC_SKIN}" != "${UI_TYPE}" ];then
		nvram set sc_skin="${UI_TYPE}"
		nvram commit
	fi

	# compatibile
	if [ "${UI_TYPE}" == "ASUSWRT" ];then
		ln -sf /jffs/softcenter/res/softcenter_asus.css /jffs/softcenter/res/softcenter.css
	elif [ "${UI_TYPE}" == "ROG" ];then
		ln -sf /jffs/softcenter/res/softcenter_rog.css /jffs/softcenter/res/softcenter.css
	elif [ "${UI_TYPE}" == "TUF" ];then
		ln -sf /jffs/softcenter/res/softcenter_tuf.css /jffs/softcenter/res/softcenter.css
	elif [ "${UI_TYPE}" == "TS" ];then
		ln -sf /jffs/softcenter/res/softcenter_ts.css /jffs/softcenter/res/softcenter.css
	fi
}

install_now() {
	if [ "$softcenter_firmware_version" = "" -o "$(versioncmp 5.2.2 $softcenter_firmware_version)" = "-1" ]; then
		echo_date "固件版本过低无法安装"
		rm -fr /tmp/softcenter* >/dev/null 2>&1
		rm -fr /tmp/upload/softcenter* >/dev/null 2>&1
		exit 0
	fi
	if [ -d "/tmp/softcenter" ]; then
		# make some folders
		mkdir -p /jffs/configs/dnsmasq.d
		mkdir -p /jffs/scripts
		mkdir -p /jffs/etc
		mkdir -p /jffs/softcenter/etc/
		mkdir -p /jffs/softcenter/bin/
		mkdir -p /jffs/softcenter/init.d/
		mkdir -p /jffs/softcenter/scripts/
		mkdir -p /jffs/softcenter/configs/
		mkdir -p /jffs/softcenter/webs/
		mkdir -p /jffs/softcenter/res/
		
		# remove useless files
		[ -L "/jffs/configs/profile" ] && rm -rf /jffs/configs/profile
		
		# coping files
		cp -rf /tmp/softcenter/webs/* /jffs/softcenter/webs/
		cp -rf /tmp/softcenter/res/* /jffs/softcenter/res/

		#cp -rf /tmp/softcenter/init.d/* /jffs/softcenter/init.d/
		cp -rf /tmp/softcenter/bin/* /jffs/softcenter/bin/
		cp -rf /tmp/softcenter/scripts/* /jffs/softcenter/scripts
		cp -rf /tmp/softcenter/.soft_ver /jffs/softcenter/
		set_skin
		dbus set softcenter_version=`cat /jffs/softcenter/.soft_ver`

		if [ -f "/jffs/softcenter/scripts/ks_tar_intall.sh" ];then
			rm -rf /jffs/softcenter/scripts/ks_tar_intall.sh
		fi
		# make some link
		if [ -f "/usr/sbin/base64_encode" ];then
			dbus set softcenter_api="1.5"
			cd /jffs/softcenter/bin && rm -rf base64_encode &&ln -sf /usr/sbin/base64_encode base64_encode
			cd /jffs/softcenter/bin && ln -sf /usr/sbin/base64_encode base64_decode
			cd /jffs/softcenter/bin && rm -rf versioncmp && ln -sf /usr/sbin/versioncmp versioncmp
			cd /jffs/softcenter/bin && rm -rf resolveip && ln -sf /usr/sbin/resolveip resolveip
		fi
		if [ -f "/usr/bin/jq" ];then
			cd /jffs/softcenter/bin && rm -rf jq && ln -sf /usr/bin/jq jq
		fi
		cd /jffs/softcenter/scripts && ln -sf ks_app_install.sh ks_app_remove.sh
		chmod 755 /jffs/softcenter/bin/*
		#chmod 755 /jffs/softcenter/init.d/*
		chmod 755 /jffs/softcenter/scripts/*

		# remove install package
		rm -rf /tmp/softcenter
		# set softcenter tcode
		/jffs/softcenter/bin/sc_auth tcode
		# set softcenter arch
		/jffs/softcenter/bin/sc_auth arch
		# creat wan-start nat-start post-mount
		if [ ! -f "/jffs/scripts/wan-start" ];then
			cat > /jffs/scripts/wan-start <<-EOF
			#!/bin/sh
			EOF
			chmod +x /jffs/scripts/wan-start
		fi
		
		if [ ! -f "/jffs/scripts/nat-start" ];then
			cat > /jffs/scripts/nat-start <<-EOF
			#!/bin/sh
			EOF
			chmod +x /jffs/scripts/nat-start
		fi
		
		if [ ! -f "/jffs/scripts/post-mount" ];then
			cat > /jffs/scripts/post-mount <<-EOF
			#!/bin/sh
			EOF
			chmod +x /jffs/scripts/post-mount
		fi
	fi
	rm -fr /tmp/softcenter* >/dev/null 2>&1
	exit 0
}

install(){
	get_model
	install_now
}

install
