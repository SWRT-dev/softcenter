#!/bin/sh
source /jffs/softcenter/scripts/base.sh

module="gostun"

values=$(dbus list gostun_ | cut -d "=" -f 1)
for value in $values; do
	dbus remove "$value"
done
rm -f /jffs/softcenter/res/icon-gostun.png
rm -f /jffs/softcenter/webs/Module_gostun.asp
rm -f /jffs/softcenter/scripts/gostun_*.sh
rm -f /jffs/softcenter/bin/gostun
echo "【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】: 卸载完成，江湖有缘再见~"
rm -f /jffs/softcenter/scripts/uninstall_gostun.sh
