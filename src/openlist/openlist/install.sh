#!/bin/sh
source /jffs/softcenter/scripts/base.sh
eval $(dbus export openlist_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)

# 皮肤相关操作交由软件中心主安装脚本

if [ "$openlist_enable" == "1" ];then
	echo_date 先关闭openlist，保证文件更新成功!
	[ -f "/jffs/softcenter/scripts/openlist_config.sh" ] && sh /jffs/softcenter/scripts/openlist_config.sh stop >/dev/null 2>&1 &
fi
echo_date "开始安装openlist..."
cp -rf $DIR/bin/* /jffs/softcenter/bin/
cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
cp -rf $DIR/webs/* /jffs/softcenter/webs/
cp -rf $DIR/res/* /jffs/softcenter/res/
cp -rf $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_openlist.sh
chmod +x /jffs/softcenter/scripts/*openlist*
chmod +x /jffs/softcenter/bin/*openlist*
find /jffs/softcenter/init.d/ -name "*openlist*" | xargs rm -rf
# ln -sf /jffs/softcenter/scripts/openlist_config.sh /jffs/softcenter/init.d/S99openlist.sh
ln -sf /jffs/softcenter/scripts/openlist_config.sh /jffs/softcenter/init.d/N99openlist.sh

#for离线安装
echo_date "设置插件默认参数及软件中心注册信息..."
dbus set openlist_version="$(cat $DIR/version)"
dbus set softcenter_module_openlist_version="$(cat $DIR/version)"
dbus set softcenter_module_openlist_description="一款支持多种存储的目录文件列表程序，使用 Gin 和 Solidjs。"
dbus set softcenter_module_openlist_install=1
dbus set softcenter_module_openlist_name=openlist
dbus set softcenter_module_openlist_title="OpenList文件列表"

if [ "$openlist_enable" == "1" ];then
	echo_date "重新启动openlist插件！"
	sh /jffs/softcenter/scripts/openlist_config.sh start >/dev/null 2>&1 &
fi

echo_date "openlist插件安装完毕！"
rm -fr $DIR >/dev/null 2>&1
exit 0
