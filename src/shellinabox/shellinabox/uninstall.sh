#! /bin/sh

source /jffs/softcenter/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
eval `dbus export shellinabox_`
echo_date "删除shellinabox插件相关文件！"
if [ "${shellinabox_enable}"x = "1"x ]; then
    sh /jffs/softcenter/scripts/shellinabox_config.sh stop
fi
killall shellinaboxd
rm -rf /jffs/softcenter/init.d/*shellinabox*
rm -rf /jffs/softcenter/shellinabox
rm -rf /jffs/softcenter/res/icon-shellinabox.png
rm -rf /jffs/softcenter/webs/Module_shellinabox.asp
rm -rf /jffs/softcenter/scripts/shellinabox*
confs=`dbus list shellinabox_|cut -d "=" -f1`

for conf in $confs
do
	dbus remove $conf
done

sleep 1
dbus remove softcenter_module_shellinabox_home_url
dbus remove softcenter_module_shellinabox_install
dbus remove softcenter_module_shellinabox_md5
dbus remove softcenter_module_shellinabox_version
dbus remove softcenter_module_shellinabox_name
dbus remove softcenter_module_shellinabox_description
dbus remove softcenter_module_shellinabox_title
rm -rf /jffs/softcenter/scripts/uninstall_shellinabox.sh



