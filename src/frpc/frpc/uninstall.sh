#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
#先关闭插件
/jffs/softcenter/scripts/frpc_config.sh stop

find /jffs/softcenter/init.d/ -name "*frpc*" | xargs rm -rf
rm -rf /jffs/softcenter/bin/frpc
rm -rf /jffs/softcenter/res/icon-frpc.png
rm -rf /jffs/softcenter/scripts/frpc*.sh
rm -rf /jffs/softcenter/webs/Module_frpc.asp
echo_date "移除插件储存的运行参数..."
values=$(dbus list frpc | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date "移除插件储存的软件中心注册参数..."
values=$(dbus list softcenter_module_frpc | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date "完成 frpc 卸载"
rm -f /jffs/softcenter/scripts/uninstall_frpc.sh
