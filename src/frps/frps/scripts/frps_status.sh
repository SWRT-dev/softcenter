#! /bin/sh

source /jffs/softcenter/scripts/base.sh
TIME=$(TZ=UTC-8 date -R "+%Y-%m-%d %H:%M:%S")

pid=`pidof frps`
if [ -n "$pid" ];then
	version=`dbus get frps_client_version`
	http_response "【$TIME】frps $version 进程运行正常！PID：$pid"
else
	http_response "<span style='color: red'>【$TIME】frps 进程未运行！</span>"
fi
