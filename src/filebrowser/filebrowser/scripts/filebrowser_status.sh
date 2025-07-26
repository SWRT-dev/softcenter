#!/bin/sh

source /jffs/softcenter/scripts/base.sh

filebrowser_pid=$(pidof filebrowser)

if [ "$filebrowser_pid" -gt 0 ];then
	text="<span style='color: gold'>FileBrowser运行中...PID: $filebrowser_pid</span>"
else
	text="FileBrowser 未运行"
fi

http_response "$text"
