#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)

# 皮肤相关操作交由软件中心主安装脚本

frps_enable=`dbus get frps_enable`
if [ "$frps_enable" == "1" ];then
	echo_date "先关闭frps插件..."
	sh /jffs/softcenter/scripts/frps_config.sh stop
fi

echo_date "安装frps插件..."
cp -rf $DIR/bin/* /jffs/softcenter/bin/
cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
cp -rf $DIR/webs/* /jffs/softcenter/webs/
cp -rf $DIR/res/* /jffs/softcenter/res/
cp -rf $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_frps.sh

chmod +x /jffs/softcenter/bin/frps
chmod +x /jffs/softcenter/scripts/frps*.sh
chmod +x /jffs/softcenter/scripts/uninstall_frps.sh

# for offline install
echo_date "设置插件默认参数及软件中心注册信息..."
VERSION=$(cat $DIR/version)
dbus set frps_version="${VERSION}"
dbus set softcenter_module_frps_version="${VERSION}"
dbus set softcenter_module_frps_install="1"
dbus set softcenter_module_frps_name="frps"
dbus set softcenter_module_frps_title="frps内网穿透"
dbus set softcenter_module_frps_description="Frps路由器服务端，内网穿透利器。"

if [ "$frps_enable" == "1" ];then
	echo_date "重新开启frps插件..."
	sh /jffs/softcenter/scripts/frps_config.sh restart
fi
echo_date "frps-${VERSION}安装完毕！"
rm -fr $DIR >/dev/null 2>&1
exit 0
