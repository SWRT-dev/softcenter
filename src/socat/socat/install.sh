#! /bin/sh
source /jffs/softcenter/scripts/base.sh
eval `dbus export socat_`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)

if [ "$socat_enable"x = "1"x ] ; then
    sh /jffs/softcenter/scripts/socat_config.sh stop
fi
# 安装插件
cd $DIR
find /jffs/softcenter/init.d/ -name "*socat*"|xargs rm -rf
cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
cp -rf $DIR/webs/* /jffs/softcenter/webs/
cp -rf $DIR/res/* /jffs/softcenter/res/
cp -f $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_socat.sh

ln -sf /jffs/softcenter/scripts/socat_config.sh /jffs/softcenter/init.d/N99socat.sh
chmod 0755 /jffs/softcenter/scripts/*socat*

# 离线安装用
echo_date "设置默认值及软件中心注册信息..."
dbus set socat_version="$(cat $DIR/version)"
dbus set softcenter_module_socat_version="$(cat $DIR/version)"
dbus set softcenter_module_socat_description="Socat 端口转发"
dbus set softcenter_module_socat_install="1"
dbus set softcenter_module_socat_name="socat"
dbus set softcenter_module_socat_title="Socat端口转发"

# 完成
echo_date "Socat端口转发插件安装完毕！"
rm -rf $DIR >/dev/null 2>&1
exit 0
