#! /bin/sh

source /jffs/softcenter/scripts/base.sh

pid=`pidof vpnserver`
if [ -n "$pid" ];then
	http_response "vpnserver 进程运行中，pid：$pid"
else
	http_response "<span style='color: white'>vpnserver 进程未运行！</span>"
fi
