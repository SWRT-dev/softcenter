#!/bin/sh

source /jffs/softcenter/scripts/base.sh

pid=$(pidof openlist)

if [ "$pid" -gt 0 ];then
	text="OpenList 运行中...（PID: $pid）"
else
	text="<span style='color: red'>OpenList 未运行</span>"
fi

http_response "$text"
