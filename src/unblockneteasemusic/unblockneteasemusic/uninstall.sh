#!/bin/sh
eval `dbus export unblockneteasemusic_`
source /jffs/softcenter/scripts/base.sh

sh /jffs/softcenter/scripts/unblockneteasemusic_config.sh stop

find /jffs/softcenter/init.d/ -name "*unblockneteasemusic*" | xargs rm -rf
rm -rf /jffs/softcenter/res/icon-unblockneteasemusic.png
rm -rf /jffs/softcenter/res/music*.json
rm -rf /jffs/softcenter/scripts/unblockneteasemusic*.sh
rm -rf /jffs/softcenter/webs/Module_unblockneteasemusic.asp
rm -rf /jffs/softcenter/bin/node
rm -rf /jffs/softcenter/bin/Music
rm -f /jffs/softcenter/scripts/uninstall_unblockneteasemusic.sh
