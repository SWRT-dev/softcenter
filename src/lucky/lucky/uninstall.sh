#!/bin/sh
eval $(dbus export lucky_)
source /jffs/softcenter/scripts/base.sh

if [ "$lucky_enable" == "1" ];then
	echo_date "先关闭Luckky插件！"
	sh /jffs/softcenter/scripts/lucky_config.sh stop
fi

find /jffs/softcenter/init.d/ -name "*lucky*" | xargs rm -rf
rm -rf /jffs/softcenter/bin/lucky 2>/dev/null
rm -rf /tmp/lucky 2>/dev/null
rm -rf /jffs/softcenter/res/icon-lucky.png 2>/dev/null
rm -rf /jffs/softcenter/scripts/lucky*.sh 2>/dev/null
rm -rf /jffs/softcenter/webs/Module_lucky.asp 2>/dev/null
rm -rf /jffs/softcenter/scripts/lucky_install.sh 2>/dev/null
rm -rf /jffs/softcenter/scripts/uninstall_lucky.sh 2>/dev/null
rm -rf /jffs/softcenter/configs/lucky 2>/dev/null
rm -rf /tmp/upload/lucky* 2>/dev/null

dbus remove lucky_version
dbus remove lucky_binary
dbus remove lucky_watchdog
dbus remove lucky_enable
dbus remove lucky_port
dbus remove lucky_reset_disable
dbus remove lucky_reset_port
dbus remove lucky_reset_safeurl
dbus remove lucky_reset_user
dbus remove lucky_safeurl
dbus remove softcenter_module_lucky_name
dbus remove softcenter_module_lucky_install
dbus remove softcenter_module_lucky_version
dbus remove softcenter_module_lucky_title
dbus remove softcenter_module_lucky_description
