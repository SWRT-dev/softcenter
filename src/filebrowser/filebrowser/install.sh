#! /bin/sh

source /jffs/softcenter/scripts/base.sh
eval $(dbus export filebrowser_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)

# 皮肤相关操作交由软件中心主安装脚本

filebrowser_pid=$(pidof filebrowser)
if [ -n "$filebrowser_pid" ];then
	echo_date 先关闭filebrowser，保证文件更新成功!
	[ -f "/jffs/softcenter/scripts/filebrowser_start.sh" ] && sh /jffs/softcenter/scripts/filebrowser_start.sh stop
fi

echo_date 清理旧文件
if [ -f "/jffs/softcenter/bin/filebrowser.db" ];then
	echo_date 发现数据库文件/jffs/softcenter/bin/filebrowser.db
	echo_date 将保留数据库。若要重置配置，请手动删除后重启服务。
fi
find /jffs/softcenter/scripts/ -name "filebrowser*.sh" | xargs rm -rf
rm -rf /jffs/softcenter/webs/Module_filebrowser*
rm -rf /jffs/softcenter/res/icon-filebrowser.png
rm -rf /jffs/softcenter/bin/filebrowser
find /jffs/softcenter/init.d/ -name "*filebrowser.sh" | xargs rm -rf

echo_date 开始复制文件！
cd $DIR
echo_date 复制相关二进制文件！此步时间可能较长！
cp -rf $DIR/bin/* /jffs/softcenter/bin/

echo_date 复制相关的脚本文件！
cp -rf $DIR/scripts/* /jffs/softcenter/scripts/
cp -rf $DIR/uninstall.sh /jffs/softcenter/scripts/uninstall_filebrowser.sh

echo_date 复制相关的网页文件！
cp -rf $DIR/webs/* /jffs/softcenter/webs/
cp -rf $DIR/res/* /jffs/softcenter/res/

echo_date 为新安装文件赋予执行权限...
chmod 755 /jffs/softcenter/scripts/*filebrowser*
chmod 755 /jffs/softcenter/bin/filebrowser*

echo_date 创建一些文件的软链接！
[ ! -L "/jffs/softcenter/init.d/N99filebrowser.sh" ] && ln -sf /jffs/softcenter/scripts/filebrowser_start.sh /jffs/softcenter/init.d/N99filebrowser.sh
	
# 离线安装时设置软件中心内储存的版本号等
echo_date 清除冗余运行参数
values=$(dbus list filebrowser_ | cut -d "=" -f 1)
for value in $values
do
	dbus remove $value
done
echo_date 设置初始值及软件中心注册信息
CUR_VERSION=$(cat $DIR/version)
dbus set filebrowser_version="$CUR_VERSION"
dbus set softcenter_module_filebrowser_install="1"
dbus set softcenter_module_filebrowser_version="$CUR_VERSION"
dbus set softcenter_module_filebrowser_title="FileBrowser"
dbus set softcenter_module_filebrowser_name="FileBrowser"
dbus set softcenter_module_filebrowser_description="FileBrowser：您的可视化路由文件管理系统"

echo_date 一点点清理工作...
rm -rf $DIR >/dev/null 2>&1
echo_date filebrowser插件安装成功！
exit 0
