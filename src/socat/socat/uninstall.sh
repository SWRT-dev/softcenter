#!/bin/sh

eval `dbus export socat_`
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

/jffs/softcenter/scripts/socat_config.sh stop
echo_date 只删除web界面和启动脚本，二进制仍在。

find /jffs/softcenter/init.d/ -name "*socat*"|xargs rm -rf
rm -f /jffs/softcenter/scripts/socat_config.sh
rm -f /jffs/softcenter/scripts/socat_status.sh
rm -f /jffs/softcenter/webs/Module_socat.asp
rm -f /jffs/softcenter/res/icon-socat.png

echo_date "移除插件储存的运行参数..."
values=`dbus list socat_ | cut -d "=" -f 1`
for value in $values
do
dbus remove $value 
done
echo_date "移除插件储存的软件中心注册参数..."
values=$(dbus list softcenter_module_socat | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done

echo_date "socat 端口转发 已卸载"
rm -f /jffs/softcenter/scripts/uninstall_socat.sh
