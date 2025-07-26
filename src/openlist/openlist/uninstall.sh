#!/bin/sh
eval `dbus export openlist_`
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'

echo_date "移除openlist插件相关文件..."
sh /jffs/softcenter/scripts/openlist_config.sh stop

[ -n "$openlist_data_dir"  ] && DATA="$openlist_data_dir" || DATA=/jffs/softcenter/openlist
echo_date "当前数据目录 $DATA 被保留，请手动处理。"
# rm -rf $DATA
find /jffs/softcenter/init.d/ -name "*openlist*" | xargs rm -rf
rm -rf /jffs/softcenter/scripts/openlist_config.sh
rm -rf /jffs/softcenter/webs/Module_openlist.asp
rm -rf /jffs/softcenter/res/*openlist*
rm -rf /jffs/softcenter/bin/openlist

echo_date "移除插件储存的运行参数..."
values=$(dbus list openlist_ | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date "移除插件储存的软件中心注册参数..."
values=$(dbus list softcenter_module_openlist | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date "完成 openlist 卸载"
rm -rf /jffs/softcenter/scripts/uninstall_openlist.sh
