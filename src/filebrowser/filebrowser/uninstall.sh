#!/bin/sh
eval `dbus export filebrowser_`
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

sh /jffs/softcenter/scripts/filebrowser_start.sh stop

echo_date "移除插件相关文件..."
if [ -f "/jffs/softcenter/bin/filebrowser.db" ];then
	echo_date 发现数据库文件/jffs/softcenter/bin/filebrowser.db，将保留。
	echo_date "若不需要数据库文件，或者要全新配置，请手动删除。"
fi
# rm -rf /jffs/softcenter/bin/filebrowser.db
find /jffs/softcenter/init.d/ -name "*filebrowser*" | xargs rm -rf
find /jffs/softcenter/scripts/ -name "filebrowser*.sh" | xargs rm -rf
rm -rf /jffs/softcenter/bin/filebrowser
rm -rf /tmp/upload/FileBrowser.log
rm -rf /jffs/softcenter/res/icon-filebrowser.png
rm -rf /jffs/softcenter/webs/Module_filebrowser.asp

echo_date "移除插件储存的运行参数..."
values=$(dbus list filebrowser_ | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done

echo_date "移除插件储存的软件中心注册参数..."
values=$(dbus list softcenter_module_filebrowser | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date "完成 filebrowser 卸载"
rm -rf /jffs/softcenter/scripts/uninstall_filebrowser.sh
