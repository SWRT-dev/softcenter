#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

sh /jffs/softcenter/scripts/frps_config.sh stop >/dev/null 2>&1

echo_date "移除插件相关文件..."
find /jffs/softcenter/init.d/ -name "*frps*" | xargs rm -rf
rm -rf /jffs/softcenter/res/icon-frps.png
rm -rf /jffs/softcenter/scripts/frps_*.sh
rm -rf /jffs/softcenter/webs/Module_frps.asp
rm -rf /jffs/softcenter/bin/frps

echo_date "移除插件储存的运行参数..."
values=$(dbus list frps | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date "移除插件储存的软件中心注册参数..."
values=$(dbus list softcenter_module_frps | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date "完成 frps 卸载"
rm -f /jffs/softcenter/scripts/uninstall_frps.sh
