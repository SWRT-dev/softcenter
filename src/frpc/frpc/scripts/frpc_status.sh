#! /bin/sh

source /jffs/softcenter/scripts/base.sh
TIME=$(TZ=UTC-8 date -R "+%Y-%m-%d %H:%M:%S")

if [ ! -f /jffs/softcenter/bin/frpc ]; then
	http_response "【$TIME】Frpc 主程序文件不存在"
	exit
fi

pid=`pidof frpc`
if [ -n "$pid" ];then
	version=`dbus get frpc_client_version`
	http_response "【$TIME】Frpc $version 进程运行正常！PID：$pid"
else
	http_response "<span style='color: red'>【$TIME】Frpc 进程未运行！</span>"
fi
