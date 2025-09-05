#!/bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)

frpc_enable=`dbus get frpc_enable`

if [ "$frpc_enable" == "1" ];then
	echo_date "先关闭frpc，保证文件更新成功!"
	/jffs/softcenter/scripts/frpc_config.sh stop
fi

echo_date 复制文件...
cp -rf $DIR/bin/* /jffs/softcenter/bin/
cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
cp -rf $DIR/webs/* /jffs/softcenter/webs/
cp -rf $DIR/res/* /jffs/softcenter/res/
cp -rf $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_frpc.sh

chmod +x /jffs/softcenter/bin/frpc
chmod +x /jffs/softcenter/scripts/frpc*.sh
chmod +x /jffs/softcenter/scripts/uninstall_frpc.sh

# for offline install
echo_date "设置插件默认参数及软件中心注册信息..."
dbus set frpc_version="$(cat $DIR/version)"
dbus set softcenter_module_frpc_version="$(cat $DIR/version)"
dbus set softcenter_module_frpc_install="1"
dbus set softcenter_module_frpc_name="frpc"
dbus set softcenter_module_frpc_title="frpc内网穿透"
dbus set softcenter_module_frpc_description="支持多种协议的内网穿透软件"

if [ "$frpc_enable" == "1" ];then
	echo_date "重新启动插件！"
	sh /jffs/softcenter/scripts/frpc_config.sh start
fi
echo_date "frpc内网穿透插件安装完毕！"
rm -fr $DIR >/dev/null 2>&1
exit 0
