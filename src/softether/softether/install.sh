#! /bin/sh
source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)
enable=`dbus get softether_enable`

#旧版文件名不同要删除
if [ -f "/jffs/softcenter/scripts/softether.sh" ];then
	sh /jffs/softcenter/scripts/softether.sh stop
	echo_date "删除冗余旧版文件..."
	rm -f /jffs/softcenter/scripts/softether.sh
	rm -f /jffs/softcenter/init.d/?98SoftEther.sh
fi

sh /jffs/softcenter/scripts/softether_config.sh stop >/dev/null 2>&1
# 安装插件
echo_date "插件安装中..."
cd $DIR
find /jffs/softcenter/init.d/ -name "*SoftEther*"|xargs rm -rf
cp -rf $DIR/bin/* /jffs/softcenter/bin/
cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
cp -rf $DIR/webs/* /jffs/softcenter/webs/
cp -rf $DIR/res/* /jffs/softcenter/res/
cp -rf $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_softether.sh

chmod 755 /jffs/softcenter/bin/vpn*
chmod 755 /jffs/softcenter/scripts/*softether*
# ln -sf /jffs/softcenter/scripts/softether_config.sh /jffs/softcenter/init.d/S98softether.sh
ln -sf /jffs/softcenter/scripts/softether_config.sh /jffs/softcenter/init.d/N98softether.sh

# 离线安装用
dbus set softether_version="$(cat $DIR/version)"
dbus set softcenter_module_softether_version="$(cat $DIR/version)"
dbus set softcenter_module_softether_description="VPN全家桶"
dbus set softcenter_module_softether_install="1"
dbus set softcenter_module_softether_name="softether"
dbus set softcenter_module_softether_title="SoftEther_VPN_Server"

# 重启服务
if [ "$enable" == "1" ];then
	echo_date "重启插件..."
	/jffs/softcenter/scripts/softether_config.sh start
fi
# 清理
rm -rf $DIR >/dev/null 2>&1

echo_date "SoftEther_VPN_Server插件安装完毕！"
exit 0

