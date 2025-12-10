#!/bin/sh

source /jffs/softcenter/scripts/base.sh
#eval `dbus export unblockneteasemusic_`
pid=`pidof node`
if [ -n "$pid" ];then
	http_response " 进程运行正常！PID：$pid"
else
	http_response "<span style='color: red'> 进程未运行！</span>"
fi

