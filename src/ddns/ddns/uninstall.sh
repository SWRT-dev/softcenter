#!/bin/sh

sh /jffs/softcenter/scripts/ddns_config.sh stop

rm -rf /jffs/softcenter/res/icon-ddns.png
rm -rf /jffs/softcenter/scripts/ddns*
rm -rf /jffs/softcenter/webs/Module_ddns.asp
rm -rf /jffs/softcenter/init.d/*ddns.sh
rm -rf /jffs/softcenter/bin/ddns-go
if [ -f "/jffs/softcenter/bin/.ddns_go_config.yaml" ];then
	mkdir -p /tmp/bak
	echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】: 发现隐藏的配置文件/jffs/softcenter/bin/.ddns_go_config.yaml，移动至临时目录/tmp/bak，重启路由器丢失，有需要请尽快备份！
	mv -f /jffs/softcenter/bin/.ddns_go_config.yaml /tmp/bak/
fi
rm -rf /jffs/softcenter/scripts/uninstall_ddns.sh
