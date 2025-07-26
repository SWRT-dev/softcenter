#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

/jffs/softcenter/scripts/softether_config.sh stop
echo_date "正在卸载softether..."

echo_date "移除插件相关文件..."
find /jffs/softcenter/init.d/ -name "*softether*"|xargs rm -rf
rm -f /jffs/softcenter/scripts/softether_config.sh
rm -f /jffs/softcenter/scripts/softether_status.sh
rm -f /jffs/softcenter/webs/Module_softether.asp
rm -f /jffs/softcenter/res/icon-softether.png
rm -f /jffs/softcenter/bin/vpnserver
rm -f /jffs/softcenter/bin/hamcore.se2
rm -f /jffs/softcenter/bin/lang.config
# rm -f /jffs/softcenter/bin/vpncmd

if [ -f "/jffs/softcenter/bin/vpn_server.config" ]; then
	echo_date "发现配置文件 /jffs/softcenter/bin/vpn_server.config，改名vpn_server.config.old"
	mv /jffs/softcenter/bin/vpn_server.config /jffs/softcenter/bin/vpn_server.config.old
fi

#删除其他可能存在
rm -rf /jffs/softcenter/bin/backup.vpn_server.config/
rm -rf /jffs/softcenter/bin/server_log/
rm -rf /jffs/softcenter/bin/chain_certs/
rm -rf /jffs/softcenter/bin/packet_log/
rm -rf /jffs/softcenter/bin/security_log/

echo_date "移除插件储存的运行参数..."
values=`dbus list softether | cut -d "=" -f 1`
for value in $values
do
dbus remove $value 
done

echo_date "移除插件储存的软件中心注册参数..."
values=$(dbus list softcenter_module_softether | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done

echo_date "完成softether卸载"
rm -f /jffs/softcenter/scripts/uninstall_softether.sh
